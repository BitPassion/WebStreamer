//
//  UIView+Extension.swift
//  WebStreamer
//
//  Created by Yinjing Li on 1/5/21.
//

import Foundation
import UIKit

extension UIView {
    @IBInspectable
    var borderColor: UIColor? {
        get {
            return layer.borderColor != nil ? UIColor(cgColor: layer.borderColor!) : .clear
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = true
        }
    }
    
    func show(_ view: UIView, animated: Bool) {
        var parent = self
        while parent.frame.height < view.frame.height {
            parent = parent.superview!
        }
        parent.addSubview(view)
        view.frame = parent.bounds
        view.alpha = 0.0
        if animated == false {
            view.alpha = 1.0
        } else {
            UIView.animate(withDuration: 0.3) {
                view.alpha = 1.0
            }
        }
    }
    
    func shadow(_ radius: CGFloat = 6.0) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = .zero
        layer.shadowRadius = radius
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
    }
    
    func parentView() -> UIView {
        var parentView = self.superview
        var view = parentView
        while parentView != nil {
            view = parentView
            parentView = parentView?.superview
        }
        
        return view!
    }
    
    func render() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(frame.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        if let sublayers = layer.sublayers {
            for shapeLayer in sublayers {
                if shapeLayer is CAShapeLayer {
                    shapeLayer.removeFromSuperlayer()
                }
            }
        }
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func roundDashCorners(radius: CGFloat, strokeColor: UIColor) {
        if let sublayers = layer.sublayers {
            for shapeLayer in sublayers {
                if shapeLayer is CAShapeLayer {
                    shapeLayer.removeFromSuperlayer()
                }
            }
        }
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.strokeColor = strokeColor.cgColor
        mask.fillColor = nil
        mask.lineWidth = 2.0
        mask.lineDashPattern = [4, 4]
        mask.path = path.cgPath
        layer.mask = nil
        layer.addSublayer(mask)
    }
    
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while !(responder is UIViewController) {
            responder = responder?.next
            if responder == nil {
                break
            }
        }
        return (responder as? UIViewController)
    }
    
    func addAnimation() {
        layer.removeAllAnimations()
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [2.0, 0.2, 2.0]
        scaleAnimation.keyTimes = [0.0, 0.5, 1.0]
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [scaleAnimation]
        animationGroup.beginTime = 0.0
        animationGroup.duration = 1.6
        animationGroup.isRemovedOnCompletion = true
        animationGroup.fillMode = .forwards
        animationGroup.repeatCount = .infinity
        layer.add(animationGroup, forKey: "animation")
    }
}
