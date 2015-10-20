//
//  Appearance.swift
//  S10
//
//  Created by Tony Xiao on 7/31/15.
//  Copyright (c) 2015 S10. All rights reserved.
//


import UIKit
import AMPopTip
import Atlas

struct Appearance {
    
    static func setupGlobalAppearances() {
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName : UIFont(.cabinRegular, size: 16)
        ], forState: .Normal)
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            NSFontAttributeName: UIFont(.cabinRegular, size: 14)
        ], forState: .Normal)
        
        setupPopTip()
        setupConversationCell()
        setupMessageCell()
        setupMessageHeader()
        setupMessageInputToolbar()
    }
    
    static func setupPopTip() {
        AMPopTip.appearance().font = UIFont(.cabinRegular, size: 14)
        AMPopTip.appearance().popoverColor = UIColor(white: 0, alpha: 0.4)
    }
    
    static func setupConversationCell() {
        let cell = ATLConversationTableViewCell.appearance()
        cell.conversationTitleLabelFont = UIFont(.cabinRegular, size: 18)
        cell.conversationTitleLabelColor = UIColor.blackColor()
        cell.dateLabelColor = UIColor(hex: 0x91908A)
        cell.dateLabelFont = UIFont(.cabinItalic, size: 14)
        cell.lastMessageLabelFont = UIFont(.cabinRegular, size: 13)
    }
    
    static func setupMessageCell() {
        let cell = ATLMessageCollectionViewCell.appearance()
        cell.messageTextFont = UIFont(.cabinRegular, size: 14)
    }
    
    static func setupMessageHeader() {
        let header = ATLConversationCollectionViewHeader.appearance()
        header.participantLabelTextColor = UIColor.whiteColor()
        header.participantLabelFont = UIFont(.cabinRegular, size: 10)
    }
    
    static func setupMessageInputToolbar() {
        let toolbar = ATLMessageInputToolbar.appearance()
        toolbar.rightAccessoryButtonFont = UIFont(.cabinBold, size: 17)
    }
}