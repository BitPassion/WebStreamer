//
//  SwizzlingManager+UIViewController.swift
//  WebStreamer
//
//  Created by Yinjing Li on 8/17/23.
//

import UIKit
import AVKit
import os.log

public extension Notification.Name {
    static let videoPlayerWillAppear = Notification.Name("videoPlayerWillAppear")
    static let videoPlayerWillDisappear = Notification.Name("videoPlayerWillDisappear")
}

extension SwizzlingManager {
    // MARK: Public API
    
    func startSwizzlingUIViewController() {
        guard !isSwizzlingUIViewController else { return }
        
        // Swizzle UIViewController methods to swizzled implementations.
        UIViewController.swizzle()
        
        isSwizzlingUIViewController = true
        
        os_log("Started swizzling UIViewController methods.", log: .default, type: .debug)
    }
    
    func stopSwizzlingUIViewController() {
        guard isSwizzlingUIViewController else { return }
        
        // Swizzle back to original implementation.
        UIViewController.swizzle()
        
        isSwizzlingUIViewController = false
        
        os_log("Stopped swizzling UIViewController methods.", log: .default, type: .debug)
    }
}

// MARK: UIViewController Swizzling
fileprivate extension UIViewController {
    static func swizzle() {
        // Set up all swizzled methods
        UIViewController.swizzleViewWillAppear()
        UIViewController.swizzleViewWillDisappear()
    }
    
    // MARK: View wil appear
    
    @objc
    private func swizzledViewWillAppear(_ animated: Bool) {
        // Always call the original implementation.
        defer {
            self.swizzledViewWillAppear(animated)
        }
        
        // Determine if this is a view controller we
        // need to perform something special for.
        switch self {
        case let controller as AVPlayerViewController:
            // Send notification
            NotificationCenter.default.post(name: .videoPlayerWillAppear, object: controller)
        default:
            // Do nothing
            break
        }
    }
    
    /**
     Swizzle UIViewController.viewWillAppear
     */
    private static func swizzleViewWillAppear() {
        let originalSelector = #selector(UIViewController.viewWillAppear(_:))
        let swizzledSelector = #selector(UIViewController.swizzledViewWillAppear(_:))
        
        guard
            let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector)
            else {
                return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    // MARK: View will disappear
    
    @objc
    private func swizzledViewWillDisappear(_ animated: Bool) {
        // Always call the original implementation.
        defer {
            self.swizzledViewWillDisappear(animated)
        }
        
        // Determine if this is a view controller we
        // need to perform something special for.
        switch self {
        case let controller as AVPlayerViewController:
            // Send notification
            NotificationCenter.default.post(name: .videoPlayerWillDisappear, object: controller)
        default:
            // Do nothing
            break
        }
    }
    
    /**
     Swizzle UIViewController.viewWillDisappear
     */
    private static func swizzleViewWillDisappear() {
        let originalSelector = #selector(UIViewController.viewWillDisappear(_:))
        let swizzledSelector = #selector(UIViewController.swizzledViewWillDisappear(_:))
        
        guard
            let originalMethod = class_getInstanceMethod(UIViewController.self, originalSelector),
            let swizzledMethod = class_getInstanceMethod(UIViewController.self, swizzledSelector)
            else {
                return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
