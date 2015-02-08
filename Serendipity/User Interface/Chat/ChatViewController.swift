//
//  ChatViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit

@objc(ChatViewController)

class ChatViewController : BaseViewController,
                            VideoRecorderDelegate,
                            VideoPlayerDelegate,
                            StorylineDelegate {
    
    let player = VideoPlayerViewController()
    let recorder = VideoRecorderViewController()
    let storyline = StorylineViewController()
    
    var connection: Connection? {
        didSet {
            storyline.connection = connection
        }
    }
    var videoRecordingURL: NSURL?
    
    @IBOutlet weak var topContainer: UIView!
    @IBOutlet weak var bottomContainer: UIView!
    
    @IBOutlet var titleView: UIView!
    @IBOutlet weak var avatarView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avatarView.sd_setImageWithURL(connection?.user?.profilePhotoURL)
        nameLabel.text = connection?.user?.firstName
        
        navigationItem.titleView = self.titleView
        
        recorder.delegate = self
        player.delegate = self
        storyline.delegate = self
        
        addChildViewController(player)
        addChildViewController(recorder)
        addChildViewController(storyline)
        
        bottomContainer.addSubview(storyline.view)
        storyline.view.makeEdgesEqualTo(bottomContainer)

        showRecorder(nil)
    }
    
    override func viewDidLayoutSubviews() {
        avatarView.makeCircular()
    }
    
    @IBAction func showPlayer(sender: AnyObject?) {
        recorder.view.removeFromSuperview()
        topContainer.addSubview(player.view)
        player.view.makeEdgesEqualTo(topContainer)
    }
    
    @IBAction func showRecorder(sender: AnyObject?) {
        player.view.removeFromSuperview()
        topContainer.addSubview(recorder.view)
        recorder.view.makeEdgesEqualTo(topContainer)
    }
    
    // MARK: - Storyline Delegate
    
    func storyline(storyline: StorylineViewController, didSelectMessage message: Message) {
        showPlayer(storyline)
        println("videouURL \(message.videoNSURL)")
        if let videoURL = message.videoNSURL {
//            let videoURL = NSURL(string: "https://s10.blob.core.windows.net/s10-prod/12345/27372.m4v")!
            player.playVideoAtURL(videoURL)
        }
    }
    
    // MARK: - Recorder Delegate
    
    func fetchMessages() -> NSSet? {
        return connection?.messages
    }
    
    func didStopRecording(videoRecordingURL: NSURL, thumbnail: NSData) {
        if let recipientId = connection?.user?.documentID {
            AzureClient.sendMessage(videoRecordingURL, thumbnail:thumbnail, recipientId: recipientId, {
                thumbnailUrl, videoUrl, serverResult, err -> Void in
                if let fullError = err {
                    println("Error in video submission: %s", fullError.localizedDescription);
                    return
                }
                
                println(serverResult);
                println(thumbnailUrl);
                println(videoUrl);
            })
        } else {
            println(connection);
        }
    }
    
    // MARK: - Player Delegate
    
    func videoPlayerDidFinishPlayback(player: VideoPlayerViewController) {
        showRecorder(player)
    }
}
