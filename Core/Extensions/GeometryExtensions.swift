//
//  Geometry.swift
//  Taylr
//
//  Created by Tony Xiao on 4/6/15.
//  Copyright (c) 2015 S10 Inc. All rights reserved.
//

import UIKit

public let π = CGFloat(M_PI)

extension UIEdgeInsets {
    public init(inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }
}

extension CGAffineTransform {
    public init(scale: CGFloat, anchor: CGPoint = CGPoint(x: 0.5, y: 0.5)) {
        self.init(a: scale, b: 0, c: 0, d: scale, tx: 0, ty: 0)
    }
}

extension CGSize {
    public var value : NSValue { return NSValue(CGSize: self) }
    public init(side: CGFloat) {
        self.init(width: side, height: side)
    }
}

extension CGRect {
    
    public var center: CGPoint {
        return CGPoint(x: (minX + maxX) / 2, y: (minY + maxY) / 2)
    }
    
    public init(side: CGFloat) {
        self.init(width: side, height: side)
    }
    
    public init(width: CGFloat, height: CGFloat) {
        self.init(origin: CGPointZero, size: CGSize(width: width, height: height))
    }
    
    public init(center: CGPoint, width: CGFloat, height: CGFloat) {
        let origin = CGPoint(x: center.x - width / 2, y: center.y - height / 2)
        self.init(origin: origin, size: CGSize(width: width, height: height))
    }
    
    // TODO: Make this scalable from any anchor point of choice
    public func scaleFromCenter(scale: CGFloat) -> CGRect {
        return CGRect(center: center, width: scale * width, height: scale * height)
    }
}

extension UIBezierPath {
    
    // North = 0 degrees, east = 90, south = 180, west = 270
    public func addLineTo(#distance: CGFloat, bearing: CGFloat) {
        let dx = distance * sin(bearing * π / 180)
        let dy = -1 * distance * cos(bearing * π / 180) // -1 because y axis increases toward south
        addLineToPoint(currentPoint + CGPoint(x: dx, y: dy))
    }
    
    public func addLineTo(#x: CGFloat, y: CGFloat) {
        addLineToPoint(CGPoint(x: x, y: y))
    }
    
    public class func sineWave(amplitude a: CGFloat, wavelength λ: CGFloat, periods: CGFloat, phase: CGFloat = 0, pointsPerStep: CGFloat = 5)  -> UIBezierPath {
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
    public var value : NSValue { return NSValue(CGPoint: self) }
    
    public func distanceTo(point: CGPoint) -> CGFloat {
        let xDist = x - point.x
        let yDist = y - point.y
        return sqrt((xDist * xDist) + (yDist * yDist))
    }
    
    public func asVector() -> CGVector {
        return CGVector(dx: x, dy: y)
    }
}

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func * (point: CGPoint, multiplier: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * multiplier, y: point.y * multiplier)
}

public func + (point: CGPoint, vector: CGVector) -> CGPoint {
    return CGPoint(x: point.x + vector.dx, y: point.y + vector.dy)
}

public func * (vector: CGVector, multiplier: CGFloat) -> CGVector {
    return CGVector(dx: vector.dx * multiplier, dy: vector.dy * multiplier)
}

