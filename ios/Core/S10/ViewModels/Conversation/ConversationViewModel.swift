//
//  ConversationViewModel.swift
//  S10
//
//  Created by Tony Xiao on 10/15/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa
import LayerKit

public class ConversationViewModel: NSObject {
    
    let ctx: Context
    let userSubscriptions: [MeteorSubscription]
    let uploading: PropertyOf<UInt>
    let downloading: PropertyOf<UInt>
    let lastMessage: PropertyOf<LYRMessage?>
    public let conversation: LYRConversation
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let displayName: PropertyOf<String>
    public let displayStatus: PropertyOf<String>
    public let videoPlayerVM: VideoPlayerViewModel
    public let isBusy: PropertyOf<Bool>
    
    public var hasUnplayedVideo: Bool {
        return videoPlayerVM.playlist.count > 0
    }
    
    public var hasUnreadText: Bool {
        let query = ctx.layer.unreadTextMessagesQuery(conversation)
        return ctx.layer.layerClient.countForQuery(query, error: nil) > 0
    }
    
    init(_ ctx: Context, conversation: LYRConversation) {
        self.ctx = ctx
        self.conversation = conversation
        self.userSubscriptions = conversation.otherUserIds(ctx.currentUserId)
            .map { ctx.meteor.subscribe("user", $0) }
        
        let otherParticipant = conversation.otherParticipants(ctx.currentUserId).first
        let avatarURL = conversation.avatarURL ?? otherParticipant?.avatarURL
        let coverURL = conversation.coverURL ?? otherParticipant?.coverURL
        let title = conversation.title ?? otherParticipant?.displayName
        uploading = ctx.layer.countOfUploads(conversation)
        downloading = ctx.layer.countOfDownloads(conversation)
        lastMessage = ctx.layer.lastMessageOf(conversation)
        
        // Navigation TitleView
        avatar = PropertyOf(avatarURL.map { Image($0) })
        cover = PropertyOf(coverURL.map { Image($0) })
        displayName = PropertyOf(title ?? "")
        displayStatus = PropertyOf("", combineLatest(
            uploading.producer,
            downloading.producer,
            lastMessage.producer
        ).map { uploading, downloading, lastMessage in
            if uploading > 0 { return "Sending..." }
            if downloading > 0 { return "Receiving" }
            if let uid = ctx.currentUserId,
                let msg = lastMessage,
                let status = Formatters.readableStatusWithDate(msg, currentUserId: uid) {
                    return status
            }
            return ""
        })
        isBusy = PropertyOf(false, combineLatest(
            uploading.producer,
            downloading.producer
        ).map { ($0 + $1) > 0 })
        
        // VideoPlayer
        videoPlayerVM = VideoPlayerViewModel(ctx)
        super.init()
        videoPlayerVM.playlist.array = unplayedVideos()
    }
    
    // MARK: -
    
    public func sendVideo(url: NSURL, thumbnail: UIImage, duration: NSTimeInterval) {
        do {
            let metadata = try NSJSONSerialization.dataWithJSONObject([
                "duration": duration,
                "width": Int(thumbnail.size.width * thumbnail.scale),
                "height": Int(thumbnail.size.height * thumbnail.scale),
            ], options: [])
            let videoPart = LYRMessagePart(MIMEType: "video/mp4", stream: NSInputStream(URL: url))
            let thumbPart = LYRMessagePart(MIMEType: "image/jpeg+preview", data: UIImageJPEGRepresentation(thumbnail, 0.8))
            let metaPart = LYRMessagePart(MIMEType: "application/json+imageSize", data: metadata)
            
            let pushConfig = LYRPushNotificationConfiguration()
            let senderName = ctx.meteor.user.value?.displayName() ?? "Someone"
            pushConfig.alert = "\(senderName) sent you a new video."
            pushConfig.sound = "layerbell.caf"
            
            let message = try ctx.layer.layerClient.newMessageWithParts([videoPart, thumbPart, metaPart], options: [
                LYRMessageOptionsPushNotificationConfigurationKey: pushConfig
            ])
            try conversation.sendMessage(message)
        } catch let error as NSError {
            Log.error("Unable to send video", error)
        }
    }
    
    public func unplayedVideos() -> [Video] {
        // TODO: We're blatantly ignoring video right now
        return ctx.layer.unplayedVideoMessages(conversation)
            .map { videoForMessage($0) }.filter { $0 != nil }.map { $0! }
    }
    
    public func videoForMessage(message: LYRMessage) -> Video? {
        if let videoURL = message.videoPart?.fileURL,
            let metadata = message.metadataPart?.asJson() as? NSDictionary {
                var video = Video(videoURL)
                video.identifier = message.identifier.absoluteString
                video.duration = (metadata["duration"] as? NSTimeInterval) ?? 0
                return video
        }
        return nil
    }
    
    public func ensureMessageAvailable(message: LYRMessage) {
        if let thumbnailPart = message.thumbnailPart where thumbnailPart.fileURL == nil {
            do {
                _ = try? thumbnailPart.purgeContent()
                try thumbnailPart.downloadContent()
            } catch let error as NSError {
                Log.error("Unable to re-download thumbnail content", error)
            }
        }
        if let videoPart = message.videoPart where videoPart.fileURL == nil {
            do {
                try videoPart.downloadContent()
            } catch let error as NSError {
                Log.error("Unable to download video content", error)
            }
        }
    }
    
    public func markAllMessagesAsRead() {
        _ = try? conversation.markAllMessagesAsRead()
    }
    
    public func markMessageAsRead(messageId: String) {
        _ = try? ctx.layer.findMessage(messageId)?.markAsRead()
    }
    
    public func markAllNonVideoMessagesAsRead() {
        do {
            let query = ctx.layer.unreadTextMessagesQuery(conversation)
            let messages = try ctx.layer.layerClient.executeQuery(query).map { $0 as! LYRMessage }
            try ctx.layer.layerClient.markMessagesAsRead(Set(messages))
        } catch let error as NSError {
            Log.error("Unable to find unread non-video messages", error)
        }
    }
    
    public func getParticipant(participantIdentifier: String) -> Participant? {
        if let user = ctx.meteor.mainContext.existingObjectInCollection("users", documentID: participantIdentifier) as? User {
            return Participant(user: user)
        }
        return conversation.participantForId(participantIdentifier)
    }
    
    // MARK: - Actions
    
    func recipientUser() -> User? {
        if let userId = conversation.otherUserIds(ctx.currentUserId).first where conversation.participants.count == 2 {
            return ctx.meteor.mainContext.existingObjectInCollection("users", documentID: userId) as? User
        }
        return nil
    }
    
    public func reportUser(reason: String) {
        if let u = recipientUser() {
            ctx.meteor.reportUser(u, reason: reason)
        }
    }
    
    public func blockUser() {
        if let u = recipientUser() {
            ctx.meteor.blockUser(u)
        }
    }
    
    public func canNavigateToProfile() -> Bool {
        return recipientUser() != nil
    }
    
    public func profileVM() -> ProfileViewModel? {
        if let u = recipientUser() {
            return ProfileViewModel(ctx, user: u)
        }
        return nil
    }
}