//
//  AppDelegate.swift
//  WebStreamer
//
//  Created by Yinjing Li on 7/31/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    //var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        /*
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let name = Utilities.isPhone ? "Main" : "Main_iPad"
        let controller = UIStoryboard(name: name, bundle: nil).instantiateInitialViewController()
        window?.rootViewController = controller
        window?.makeKeyAndVisible()
        */
        
        ScreenRecorder.shared.orientation = UIApplication.orientation()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        if Utilities.isPhone {
            return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        } else {
            return UISceneConfiguration(name: "iPad Configuration", sessionRole: connectingSceneSession.role)
        }
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

