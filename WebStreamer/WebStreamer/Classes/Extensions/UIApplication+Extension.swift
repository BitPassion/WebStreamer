//
//  UIApplication+Extension.swift
//  WebStreamer
//
//  Created by Yinjing Li on 2/8/23.
//

import Foundation
import UIKit

@objc extension UIApplication {
    @objc var isLandscape: Bool {
        return UIApplication.orientation() == .landscapeLeft || UIApplication.orientation() == .landscapeRight
    }
    
    @objc func topViewController() -> UIViewController? {
        var topViewController: UIViewController? = nil
        if #available(iOS 13, *) {
            for scene in connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    for window in windowScene.windows {
                        if window.isKeyWindow {
                            topViewController = window.rootViewController
                        }
                    }
                }
            }
        } else {
            topViewController = keyWindow?.rootViewController
        }
        while true {
            if let presented = topViewController?.presentedViewController {
                topViewController = presented
            } else if let navController = topViewController as? UINavigationController {
                topViewController = navController.topViewController
            } else if let tabBarController = topViewController as? UITabBarController {
                topViewController = tabBarController.selectedViewController
            } else {
                // Handle any other third party container in `else if` if required
                break
            }
        }
        return topViewController
    }
    
    @objc func customizeNavigationBar() {
        let barAppearance = UINavigationBar.appearance()
        barAppearance.isTranslucent = false
        barAppearance.clipsToBounds = false
        
        let titleTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.black,
            .font: UIFont(name: "MyriadPro-Bold", size: 17.0)!
        ]
        
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = UIColor.white
            appearance.titleTextAttributes = titleTextAttributes

            barAppearance.standardAppearance = appearance
            barAppearance.scrollEdgeAppearance = appearance
            
            let backTextAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor.black,
                .font: UIFont(name: "MyriadPro-Semibold", size: 16.0)!
            ]
            let backButtonAppearance = UIBarButtonItemAppearance()
            backButtonAppearance.normal.titleTextAttributes = backTextAttributes
            appearance.backButtonAppearance = backButtonAppearance
        } else {
            barAppearance.barTintColor = UIColor.white
            barAppearance.titleTextAttributes = titleTextAttributes
        }
        barAppearance.tintColor = .black
    }
    
    @objc func windowScene() -> UIWindowScene? {
        if #available(iOS 13, *) {
            for scene in connectedScenes {
                if let windowScene = scene as? UIWindowScene {
                    return windowScene
                }
            }
        } else {
            return nil
        }
        
        return nil
    }
}
