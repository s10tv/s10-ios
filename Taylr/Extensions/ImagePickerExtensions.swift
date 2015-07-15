//
//  ImagePickerExtensions.swift
//  S10
//
//  Created by Tony Xiao on 7/15/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit

extension UIViewController {
    func pickImage(block: (UIImage) -> ()) {
        let picker = UIImagePickerController()
        picker.rac_imageSelectedSignal().subscribeNext({
            if let info = $0 as? NSDictionary,
                let image = (info[UIImagePickerControllerEditedImage]
                    ?? info[UIImagePickerControllerOriginalImage]) as? UIImage {
                        block(image)
            }
            picker.dismissViewController(animated: true)
            }, completed: {
                picker.dismissViewController(animated: true)
        })
        presentViewController(picker, animated: true)
    }
}

