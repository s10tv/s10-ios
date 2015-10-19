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
    public let avatar: PropertyOf<Image?>
    public let cover: PropertyOf<Image?>
    public let displayName: ProducerProperty<String>
    public let displayStatus = PropertyOf("")
    
    public let conversation: LYRConversation
    
    init(_ ctx: Context, conversation: LYRConversation) {
        self.ctx = ctx
        self.conversation = conversation
        if let u = conversation.recipient(ctx.meteor.mainContext, currentUserId: ctx.currentUserId) {
            avatar = u.pAvatar()
            cover = u.pCover()
            displayName = u.pDisplayName()
        } else {
            avatar = PropertyOf(nil)
            cover = PropertyOf(nil)
            displayName = ProducerProperty(SignalProducer(value: ""))
        }
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
    
    public func videoForMessage(message: LYRMessage) -> VideoMessageViewModel? {
        if let videoURL = message.videoPart?.fileURL,
            let metadata = message.metadataPart?.asJson() as? NSDictionary {
                let duration = (metadata["duration"] as? NSTimeInterval) ?? 0
                return VideoMessageViewModel(identifier: message.identifier.absoluteString, url: videoURL, duration: duration)
        }
        return nil
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
    
    public func receiveVM() -> ReceiveViewModel {
        return ReceiveViewModel(ctx, conversation: conversation)
    }
    
    public func profileVM() -> ProfileViewModel? {
        if let u = user() {
            return ProfileViewModel(ctx, user: u)
        }
        return nil
    }
}