//
//  SwizzlingManager.swift
//  WebStreamer
//
//  Created by Yinjing Li on 8/17/23.
//

import UIKit

class SwizzlingManager: NSObject {

    /// Singleton.
    public static let shared = SwizzlingManager()
    
    /// Whether or not UIViewController is being swizzled.
    public internal(set) var isSwizzlingUIViewController = false
    
    // MARK: Lifecycle
    
    /// Initialization.
    override init() {
        // Do not allow non-private initialization.
        super.init()
    }
    
    /// Deinitialization.
    deinit {
        // Clean up
        stopSwizzling()
    }
    
    func startSwizzling() {
        startSwizzlingUIViewController()
    }
    
    func stopSwizzling() {
        stopSwizzlingUIViewController()
    }
}
