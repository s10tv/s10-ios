//
//  SettingsTextCell.swift
//  Taylr
//
//  Created by Tony Xiao on 4/16/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import UIKit
import XLForm

class SettingsTextCell : XLFormBaseCell {
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var textView: XLFormTextView!
    
    var row: RowDescriptor? { return rowDescriptor as? RowDescriptor }

    override func configure() {
        super.configure()
        textView.delegate = self
        textView.placeholderColor = StyleKit.teal.colorWithAlpha(0.3)
        textView.placeholder = ""
        NC.addObserver(textView, selector: "textChanged:", name: UITextViewTextDidChangeNotification, object: nil)
    }
    
    override func update() {
        super.update()
        iconView.image = UIImage(named: rowDescriptor.title)
        textView.placeholder = rowDescriptor.noValueDisplayText
        textView.text = row?.formattedValue
        textView.editable = !rowDescriptor.disabled
        textView.selectable = !rowDescriptor.disabled
        if let inputView = row?.inputView {
            textView.inputView = inputView
            textView.tintColor = UIColor.clearColor()
        }
    }
    
    override func formDescriptorCellCanBecomeFirstResponder() -> Bool {
        return !rowDescriptor.disabled
    }
    
    override func formDescriptorCellBecomeFirstResponder() -> Bool {
        return textView.becomeFirstResponder()
    }
    
    func forceUpdateHeight() {
        // Force tableview to recalculate height
// BUGBUG: SettingsViewModel is not being deallocated. mem leak causing crash, use optional temporarily to avoid crash
        formViewController()?.tableView.beginUpdates()
        formViewController()?.tableView.endUpdates()
    }
}

// MARK: -

extension SettingsTextCell : UITextViewDelegate {
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        return formViewController().textViewShouldBeginEditing(textView)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        // NOTE: To make this work better for the
        if row?.inputView == nil {
            textView.text = rowDescriptor.value as? String
        }
        formViewController().beginEditing(rowDescriptor)
        formViewController().textViewDidBeginEditing(textView)
        row?.beginEditing()
    }
    
    func textViewDidChange(textView: UITextView) {
        forceUpdateHeight()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        rowDescriptor.value = textView.text.length > 0 ? textView.text : nil
        textView.text = row?.formattedValue
        formViewController().endEditing(rowDescriptor)
        formViewController().textViewDidEndEditing(textView)
        row?.endEditing()
        forceUpdateHeight()
    }
}