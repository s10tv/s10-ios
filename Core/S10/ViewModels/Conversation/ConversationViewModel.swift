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
    public let conversation: LYRConversation
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let displayName: ProducerProperty<String>
    public let displayStatus = PropertyOf("")
    public let videoPlayerVM: VideoPlayerViewModel
    
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
        if let u = conversation.recipient(ctx.meteor.mainContext, currentUserId: ctx.currentUserId) {
            avatar = u.pAvatar()
            cover = u.pCover()
            displayName = u.pDisplayName()
        } else {
            let otherUserId = conversation.recipientId(ctx.currentUserId)!
            avatar = PropertyOf(conversation.getUserAvatarURL(otherUserId).map { Image($0) })
            cover = PropertyOf(conversation.getUserCoverURL(otherUserId).map { Image($0) })
            displayName = ProducerProperty(SignalProducer(value: conversation.getUserDisplayName(otherUserId) ?? ""))
        }
        videoPlayerVM = VideoPlayerViewModel(ctx)
        super.init()
        videoPlayerVM.playlist.array = unplayedVideos()
    }
    
    func user() -> User? {
        return conversation.recipient(ctx.meteor.mainContext, currentUserId: ctx.currentUserId)
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
        return ctx.layer.unplayedVideoMessages(conversation).map { videoForMessage($0)! }
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
    
    public func getUser(userId: String) -> UserViewModel? {
        if let u = ctx.meteor.mainContext.existingObjectInCollection("users", documentID: userId) as? User {
            return UserViewModel(user: u)
        }
        return nil
    }
    
    public func reportUser(reason: String) {
        if let u = user() {
            ctx.meteor.reportUser(u, reason: reason)
        }
    }
    
    public func blockUser() {
        if let u = user() {
            ctx.meteor.blockUser(u)
        }
    }
    
    public func profileVM() -> ProfileViewModel? {
        if let u = user() {
            return ProfileViewModel(ctx, user: u)
        }
        return nil
    }
}