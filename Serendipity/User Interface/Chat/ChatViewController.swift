//
//  ChatViewController.swift
//  Serendipity
//
//  Created by Tony Xiao on 1/28/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit

@objc(ChatViewController)
class ChatViewController : BaseViewController, VideoRecorderDelegate {
    
    let player = VideoPlayerViewController()
    let recorder = VideoRecorderViewController()
    var connection: Connection?
    var videoRecordingURL: NSURL?
    
    @IBOutlet weak var topContainer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(player)
        addChildViewController(recorder)
        
        recorder.delegate = self
        showRecorder(nil)
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
    
    // MARK: - 
    
    func didStartRecording(videoURL: NSURL) {
        self.videoRecordingURL = videoURL;
    }
    
    func didStopRecording() {
        if let recipientId = connection?.user?.documentID {
            AzureClient.updateConnectionsInfo(videoRecordingURL!, recipientId: recipientId, {
                blobid, serverResult, err -> Void in
                if let fullError = err {
                    println("Error in video submission: %s", fullError.localizedDescription);
                    return
                }
                
                println(serverResult);
                println(blobid);
            })
        } else {
            println(connection);
        }
    }
    
}
