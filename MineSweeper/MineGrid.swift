//
//  MineGrid.swift
//  MineSweeper
//
//  Created by 风筝 on 2017/10/10.
//  Copyright © 2017年 Doge Studio. All rights reserved.
//

import UIKit

protocol MineGridDelegate: class {
    func open(row: Int, column: Int)
    func openArround(row: Int, column: Int)
}

class MineGrid: UIControl {
    
    let rowIndex: Int
    let columnIndex: Int
    weak var delegate: MineGridDelegate?
    var mineNumber: Int = 0 {
        didSet {
            if self.mineNumber == -1 {
                self.mineLayer.contents = self.mineImage.cgImage
                self.mineNumberLayer.string = ""
                self.mineLayer.backgroundColor = self.boomBackgroundColor.cgColor
            } else {
                self.mineLayer.contents = nil
                if self.mineNumber > 0 {
                    self.mineNumberLayer.string = "\(self.mineNumber)"
                } else {
                    self.mineNumberLayer.string = ""
                }
                self.mineLayer.backgroundColor = self.openedBackgroundColor.cgColor
            }
        }
    }
    var isMarked: Bool = false {
        didSet {
            self.coverLayer.contents = self.isMarked ? self.flagImage.cgImage : nil
        }
    }
    var isOpened: Bool {
        get {
            return self.openStatus
        }
    }
    
    var fontColor: UIColor = 0x0288D1.rgbColor
    var normalBackgroundColor: UIColor = 0x03A9F4.rgbColor
    var highlightedBackgroundColor: UIColor = 0x0288D1.rgbColor
    var openedBackgroundColor: UIColor = 0xE1F5FE.rgbColor
    var boomBackgroundColor: UIColor = 0xE51C23.rgbColor
    var flagImage: UIImage = #imageLiteral(resourceName: "flag")
    var mineImage: UIImage = #imageLiteral(resourceName: "mine")
    
    fileprivate let mineLayer: CALayer = CALayer()
    fileprivate let mineNumberLayer: CATextLayer = CATextLayer()
    fileprivate let coverLayer: CALayer = CALayer()
    fileprivate var openStatus: Bool = false
    
    init(rowIndex: Int, columnIndex: Int) {
        self.rowIndex = rowIndex
        self.columnIndex = columnIndex
        super.init(frame: CGRect.zero)
        
        self.layer.addSublayer(self.mineLayer)
        self.mineLayer.addSublayer(self.mineNumberLayer)
        self.layer.addSublayer(self.coverLayer)
        var transform = CATransform3DIdentity
        transform.m34 = -1.0 / 400.0
        self.layer.sublayerTransform = transform
        
        self.mineLayer.frame = self.bounds
        self.mineLayer.backgroundColor = openedBackgroundColor.cgColor
        self.mineNumberLayer.frame = self.bounds.offsetBy(dx: 0, dy: 8)
        self.mineNumberLayer.fontSize = 22
        self.mineNumberLayer.foregroundColor = self.fontColor.cgColor
        self.mineNumberLayer.contentsScale = UIScreen.main.scale
        self.mineNumberLayer.alignmentMode = kCAAlignmentCenter
        self.mineNumberLayer.foregroundColor = self.fontColor.cgColor
        self.coverLayer.frame = self.bounds
        self.coverLayer.backgroundColor = normalBackgroundColor.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = newValue
            self.mineLayer.frame = self.bounds
            self.mineNumberLayer.frame = self.bounds.offsetBy(dx: 0, dy: 8)
            self.coverLayer.frame = self.bounds
        }
    }
    
    func open() {
        if self.openStatus {
            return
        }
        self.openStatus = true
        openAnimation()
    }
    
    func reset() {
        self.mineNumber = 0
        self.isMarked = false
        self.openStatus = false
        self.coverLayer.removeAllAnimations()
        self.mineLayer.removeAllAnimations()
    }
    
    fileprivate func openAnimation() {
        let duration = 0.25
        
        let animation = CABasicAnimation(keyPath: "transform.rotation.y")
        animation.fromValue = -CGFloat.pi
        animation.toValue = 0
        animation.duration = duration
        animation.fillMode = kCAFillModeBoth
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.coverLayer.add(animation, forKey: nil)
        
        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.fromValue = 1
        opacity.toValue = 0
        opacity.beginTime = CACurrentMediaTime() + duration / 2
        opacity.duration = 0.01
        opacity.fillMode = kCAFillModeBoth
        opacity.isRemovedOnCompletion = false
        self.coverLayer.add(opacity, forKey: nil)
        
        let animation2 = CABasicAnimation(keyPath: "transform.rotation.y")
        animation2.fromValue = 0
        animation2.toValue = CGFloat.pi
        animation2.duration = duration
        animation2.fillMode = kCAFillModeBoth
        animation2.isRemovedOnCompletion = false
        animation2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        self.mineLayer.add(animation, forKey: nil)
    }
    
    fileprivate var touchDownTimestamp: TimeInterval = 0
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.touchDownTimestamp = Date().timeIntervalSince1970
        if self.openStatus {
            return true
        }
        return true
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        if self.openStatus {
            return true
        }
        if !self.isMarked {
            self.coverLayer.backgroundColor = self.highlightedBackgroundColor.cgColor
        }
        if #available(iOS 9.0, *) {
            print(touch.force)
            if touch.force >= touch.maximumPossibleForce / 2 {
                self.coverLayer.backgroundColor = self.normalBackgroundColor.cgColor
                self.delegate?.open(row: self.rowIndex, column: self.columnIndex)
                if #available(iOS 10.0, *) {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.prepare()
                    impact.impactOccurred()
                }
                return false
            }
        }
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        if Date().timeIntervalSince1970 - self.touchDownTimestamp > 0.5 {
            if !self.openStatus {
                self.coverLayer.backgroundColor = self.normalBackgroundColor.cgColor
            }
        } else {
            if self.openStatus {
                if self.mineNumber > 0 {
                    self.delegate?.openArround(row: self.rowIndex, column: self.columnIndex)
                }
            } else {
                self.coverLayer.backgroundColor = self.normalBackgroundColor.cgColor
                self.isMarked = !self.isMarked
            }
        }
    }
    
}
