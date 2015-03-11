//
//  UIKitExtension.swift
//  Serendipity
//
//  Created by Tony Xiao on 2/6/15.
//  Copyright (c) 2015 Serendipity. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Snap

let π = CGFloat(M_PI)

func LS(localizableKey: String) -> String {
    return NSLocalizedString(localizableKey, comment: "")
}

extension UIView {
    
    func makeCircular() {
        layer.cornerRadius = max(frame.size.width, frame.size.height) / 2
        layer.masksToBounds = true
    }
    
    func makeEdgesEqualTo(view: UIView) {
        snp_makeConstraints { (make) -> () in
            make.edges.equalTo(view)
            return // Hack needed to compile
        }
    }
    
    func whenTapped(block: () -> ()) {
        let tap = UITapGestureRecognizer()
        tap.numberOfTapsRequired = 1
        tap.numberOfTouchesRequired = 1
        tap.rac_gestureSignal().subscribeNextAs { (recognizer : UIGestureRecognizer) -> () in
            if recognizer.state == .Ended {
                block()
            }
        }
        addGestureRecognizer(tap)
    }

    func whenSwiped(direction: UISwipeGestureRecognizerDirection, block: () -> ()) {
        let swipe = UISwipeGestureRecognizer()
        swipe.direction = direction
        swipe.rac_gestureSignal().subscribeNextAs { (recognizer : UIGestureRecognizer) -> () in
            if recognizer.state == .Ended {
                block()
            }
        }
        addGestureRecognizer(swipe)
    }
}

extension UIAlertView {
    class func show(title: String, message: String? = nil) -> RACSignal {
        let alert = UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
        return alert.rac_buttonClickedSignal()
    }
}

extension UIBezierPath {
    
    class func sineWave(amplitude a: CGFloat, wavelength λ: CGFloat, periods: CGFloat, phase: CGFloat = 0, pointsPerStep: CGFloat = 5)  -> UIBezierPath {
        let stepLength = 2*π / λ * pointsPerStep
        let totalLength = λ * periods
        let wave = UIBezierPath()
        wave.moveToPoint(CGPointZero)
        for var x: CGFloat = stepLength; x < totalLength; x += stepLength {
            wave.addLineToPoint(CGPoint(x: x, y: a * sin(2*π/λ * x + phase)))
        }
        return wave
    }
}

func DebugPrintAllFonts() {
    for familyName in UIFont.familyNames() as [String] {
        println("Family: \(familyName)")
        for fontName in UIFont.fontNamesForFamilyName(familyName) {
            println("\tFont: \(fontName)")
        }
    }
}