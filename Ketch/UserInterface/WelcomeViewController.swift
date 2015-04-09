//
//  WelcomeViewController.swift
//  Ketch
//
//  Created by Tony Xiao on 4/9/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import Foundation

class WelcomeViewController : BaseViewController {

    @IBOutlet var cloudViews: [UIImageView]!
    @IBOutlet weak var boatView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Animate boat
        boatView.layer.animate(keyPath: "transform.rotation") { pitch, _ in
            pitch.fromValue = 0.2
            pitch.toValue = -0.2
            pitch.autoreverses = true
            pitch.duration = 3
            pitch.repeatCount = Float.infinity
        }
        
        // Animate clouds
        let screenWidth = UIScreen.mainScreen().bounds.width
        let values: [(CGFloat, CGFloat, CFTimeInterval)] = [
            (-100, screenWidth+100, 6),
            (screenWidth+100, -300, 7),
            (-200, screenWidth+300, 8),
            (screenWidth+120, -150, 9)
        ]
        Zip2(cloudViews!, values).map { (cloud, value) in
            cloud.layer.animate(keyPath: "position.x") { translate, layer in
                translate.fromValue = value.0
                translate.toValue = value.1
                translate.duration = value.2
                translate.repeatCount = Float.infinity
                layer.speed = 0.25
            }
        }
    }
    
    @IBAction func finishWelcome(sender: AnyObject) {
        // TODO: Set approval state = true
        navigationController?.popToRootViewControllerAnimated(true)
    }
}