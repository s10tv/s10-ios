//
//  ConversationViewController.swift
//  S10
//
//  Created by Tony Xiao on 10/17/15.
//  Copyright © 2015 S10. All rights reserved.
//

import UIKit
import Core

class ConversationViewController : UIViewController {
    
    @IBOutlet weak var chatHistoryContainer: UIView!
    private(set) var chatHistoryVC: ConversationHistoryViewController!
    
    var vm: ConversationViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // This is necessary because otherwise during child viewWillAppear
        // the childVC's view will have the wrong frame
        chatHistoryVC.view.makeEdgesEqualTo(chatHistoryContainer)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let vc = segue.destinationViewController as? ConversationHistoryViewController {
            assert(vm != nil, "Conversation ViewModel must be set before prepareForSegue is called")
            vc.layerClient = MainContext.layer.layerClient
            vc.vm = vm
            chatHistoryVC = vc
        }
    }
}