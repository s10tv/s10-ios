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
    
    var user: User? {
        didSet {
            storyline.connection = user?.connection
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
        
        avatarView.sd_setImageWithURL(user?.profilePhotoURL)
        nameLabel.text = user?.firstName
        titleView.whenTapped { [weak self] in
            // TODO: Avoid hard-coding segue identifier somehow
            self!.performSegueWithIdentifier("ChatToProfile", sender: nil)
        }
        
        navigationItem.titleView = titleView
        
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if user?.connection == nil && user != nil {
            // TODO: Refactor to make using localizable more bearable
            let body = NSString(format: NSLocalizedString("SendFirstMessageBody", comment: ""), user!.firstName!) as String
            UIAlertView.show(NSLocalizedString("SendFirstMessageTitle", comment: ""), message: body)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarView.makeCircular()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let profileVC = segue.destinationViewController as? ProfileViewController {
            profileVC.user = user
        }
    }
    
    // MARK: - Actions
    
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
            player.playVideoAtURL(videoURL)
        }
    }
    
    // MARK: - Recorder Delegate
    
    func didStopRecording(videoRecordingURL: NSURL, thumbnail: NSData) {
        if let recipientId = user?.documentID {
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
            println(user);
        }
    }
    
    // MARK: - Player Delegate
    
    func videoPlayerDidFinishPlayback(player: VideoPlayerViewController) {
        showRecorder(player)
    }
}
