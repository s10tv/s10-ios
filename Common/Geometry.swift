//
//  Geometry.swift
//  Ketch
//
//  Created by Tony Xiao on 4/6/15.
//  Copyright (c) 2015 Ketch. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    init(inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }
}

extension CGAffineTransform {
    init(scale: CGFloat) {
        self.init(a: scale, b: 0, c: 0, d: scale, tx: 0, ty: 0)
    }
}

extension CGRect {
    
    var center: CGPoint {
        return CGPoint(x: (minX + maxX) / 2, y: (minY + maxY) / 2)
    }
    
    init(center: CGPoint, width: CGFloat, height: CGFloat) {
        let origin = CGPoint(x: center.x - width / 2, y: center.y - height / 2)
        self.init(origin: origin, size: CGSize(width: width, height: height))
    }
    
    // TODO: Make this scalable from any anchor point of choice
    func scaleFromCenter(scale: CGFloat) -> CGRect {
        return CGRect(center: center, width: scale * width, height: scale * height)
    }
}

extension UIBezierPath {
    
    func addLineTo(#x: CGFloat, y: CGFloat) {
        addLineToPoint(CGPoint(x: x, y: y))
    }
    
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

extension CGPoint {
    func distanceTo(point: CGPoint) -> CGFloat {
        let xDist = x - point.x
        let yDist = y - point.y
        return sqrt((xDist * xDist) + (yDist * yDist))
    }
    
    func asVector() -> CGVector {
        return CGVector(dx: x, dy: y)
    }
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func * (point: CGPoint, multiplier: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * multiplier, y: point.y * multiplier)
}

func + (point: CGPoint, vector: CGVector) -> CGPoint {
    return CGPoint(x: point.x + vector.dx, y: point.y + vector.dy)
}

func * (vector: CGVector, multiplier: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx * multiplier, dy: vector.dy * multiplier)
}

