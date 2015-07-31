//
//  ConversationTutorialViewController.swift
//  S10
//
//  Created by Tony Xiao on 7/30/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit

protocol ConversationTutorialDelegate : class {
    func tutorialDidFinish()
}

class ConversationTutorialViewController : UIViewController {
    
    @IBOutlet weak var step1View: UIView!
    @IBOutlet weak var step2View: UIView!
    weak var delegate: ConversationTutorialDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clearColor()
        step2View.hidden = true
    }
    
    @IBAction func didTapNext(sender: AnyObject) {
        step1View.hidden = true
        step2View.hidden = false
    }
    
    @IBAction func didTapDone(sender: AnyObject) {
        delegate?.tutorialDidFinish()
    }
}