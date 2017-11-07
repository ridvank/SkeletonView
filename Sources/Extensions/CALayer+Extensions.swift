//
//  SkeletonLayer+Animations.swift
//  SkeletonView-iOS
//
//  Created by Juanpe Catalán on 03/11/2017.
//  Copyright © 2017 SkeletonView. All rights reserved.
//

import UIKit

extension CALayer {
    @objc func tint(withColors colors: [UIColor]) {
        recursiveSearch(inArray: skeletonSublayers,
                        leafBlock: { backgroundColor = colors.first?.cgColor }) {
                            $0.tint(withColors: colors)
        }
    }
}

extension CAGradientLayer {
    override func tint(withColors colors: [UIColor]) {
        recursiveSearch(inArray: skeletonSublayers,
                        leafBlock: { self.colors = colors.map { $0.cgColor } }) {
                            $0.tint(withColors: colors)
        }
    }
}


// MARK: Skeleton sublayers
extension CALayer {
    
    static let skeletonSubLayersName = "SkeletonSubLayersName"

    var skeletonSublayers: [CALayer] {
        return sublayers?.filter { $0.name == CALayer.skeletonSubLayersName } ?? [CALayer]()
    }
    
    func addMultilinesLayers(lines: Int, type: SkeletonType) {
        let numberOfSublayers = calculateNumLines(maxLines: lines)
        for index in 0..<numberOfSublayers {
            let layer = SkeletonLayerFactory().makeMultilineLayer(withType: type, for: index, width: Int(bounds.width))
            addSublayer(layer)
        }
    }
    
    private func calculateNumLines(maxLines: Int) -> Int {
        let spaceRequitedForEachLine = SkeletonDefaultConfig.multilineHeight + SkeletonDefaultConfig.multilineSpacing
        var numberOfSublayers = Int(round(CGFloat(bounds.height)/CGFloat(spaceRequitedForEachLine)))
        if maxLines != 0,  maxLines <= numberOfSublayers { numberOfSublayers = maxLines }
        return numberOfSublayers
    }
}

// MARK: Animations
public extension CALayer {
    
    enum Animations {
     
        static var pulse: CAAnimation {
            let pulseAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.opacity))
            pulseAnimation.duration = 1
            pulseAnimation.fromValue = 1
            pulseAnimation.toValue = 0.7
            pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            pulseAnimation.autoreverses = true
            pulseAnimation.repeatCount = .infinity
            return pulseAnimation
        }
        
        static var sliding: CAAnimation {
            let startPointAnim = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.startPoint))
            startPointAnim.fromValue = NSValue(cgPoint:CGPoint(x: -1, y: 0.5))
            startPointAnim.toValue = NSValue(cgPoint:CGPoint(x:1, y: 0.5))
            
            let endPointAnim = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.endPoint))
            endPointAnim.fromValue = NSValue(cgPoint:CGPoint(x: 0, y: 0.5))
            endPointAnim.toValue = NSValue(cgPoint:CGPoint(x:2, y: 0.5))
            
            let animGroup = CAAnimationGroup()
            animGroup.animations = [startPointAnim, endPointAnim]
            animGroup.duration = 1.5
            animGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            animGroup.repeatCount = .infinity
            
            return animGroup
        }
    }
    
    func playAnimation(_ anim: SkeletonLayerAnimation, key: String) {
        recursiveSearch(inArray: skeletonSublayers,
                        leafBlock: { add(anim(), forKey: key) }) {
                            $0.playAnimation(anim, key: key)
        }
    }
    
    func stopAnimation(forKey key: String) {
        recursiveSearch(inArray: skeletonSublayers,
                        leafBlock: { removeAnimation(forKey: key) }) {
                            $0.stopAnimation(forKey: key)
        }
    }
}