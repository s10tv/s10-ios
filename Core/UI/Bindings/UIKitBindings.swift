//
//  UIKitBindings.swift
//  S10
//
//  Created by Tony Xiao on 9/27/15.
//  Copyright © 2015 S10. All rights reserved.
//

import Foundation
import ReactiveCocoa

private var kText: UInt8 = 0
private var kTitle: UInt8 = 0
private var kHidden: UInt8 = 0
private var kAnimating: UInt8 = 0

extension UIView {
    public var rac_hidden: MutableProperty<Bool> {
        return associatedProperty(&kHidden, setter: { [weak self] in self?.hidden = $0 }, getter: { self.hidden })
    }
}

extension UIButton {
    public var rac_title: MutableProperty<String?> {
        return associatedProperty(&kTitle, setter: { [weak self] in
            self?.setTitle($0, forState: .Normal)
        }, getter: { self.titleForState(.Normal) })
    }
}

extension UILabel {
    public var rac_text: MutableProperty<String?> {
        return associatedProperty(&kText, setter: { [weak self] in self?.text = $0 }, getter: { self.text })
    }
}

extension UITextField {
    public var rac_text: MutableProperty<String?> {
        return associatedObject(&kText) { [weak self] in
            let property = MutableProperty<String?>(nil)
            self?.addTarget(self, action: "_rac_textChanged", forControlEvents: .EditingChanged)
            property.producer.startWithNext { [weak self] in
                self?.text = $0
            }
            return property
        }
    }
    
    func _rac_textChanged() {
        rac_text.value = self.text
    }
}

extension UITextView {
    public var rac_text: MutableProperty<String?> {
        return associatedObject(&kText) { [weak self] in
            let property = MutableProperty<String?>(nil)
            var updatingFromSelf = false
            self?.listenForNotification(UITextViewTextDidChangeNotification, object: self).startWithNext { [weak self] _ in
                updatingFromSelf = true
                property.value = self?.text
                updatingFromSelf = false
            }
            property.producer.startWithNext { [weak self] in
                if !updatingFromSelf {
                    self?.text = $0
                }
            }
            return property
        }
    }
}

extension UIActivityIndicatorView {
    public var rac_animating: MutableProperty<Bool> {
        return associatedObject(&kAnimating) { [weak self] in
            let property = MutableProperty<Bool>(self?.isAnimating() ?? false)
            property.producer.startWithNext { [weak self] animating in
                if animating {
                    self?.startAnimating()
                } else {
                    self?.stopAnimating()
                }
            }
            return property
        }
    }
}
