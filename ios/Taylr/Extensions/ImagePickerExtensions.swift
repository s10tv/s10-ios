//
//  ImagePickerExtensions.swift
//  S10
//
//  Created by Tony Xiao on 7/15/15.
//  Copyright (c) 2015 S10. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Core

extension UIViewController {
    func pickSingleImage(maxDimension maxDimension: CGFloat? = nil, animated: Bool = true) -> Future<UIImage, NoError> {
        let promise = Promise<UIImage, NoError>()
        let picker = UIImagePickerController()
        var gotImage = false
        picker.rac_imageSelectedSignal().subscribeNext({ info in
            if let info = info as? NSDictionary,
                let image = (info[UIImagePickerControllerEditedImage]
                    ?? info[UIImagePickerControllerOriginalImage]) as? UIImage {
                gotImage = true
                let img = maxDimension.map { image.scaleToMaxDimension($0, pixelSize: true) } ?? image
                picker.dismissViewControllerAnimated(animated) {
                    promise.success(img)
                }
            }
        }, completed: {
            if !gotImage {
                picker.dismissViewControllerAnimated(animated) {
                    promise.cancel()
                }
            }
            
        })
        presentViewController(picker, animated: animated)
        return promise.future
    }
}

