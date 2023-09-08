//
//  Utilities.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 7/21/22.
//

import UIKit

class Utilities: NSObject {
    
    static var isPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    
    static var isPad: Bool {
        return UIDevice.current.userInterfaceIdiom != .phone
    }
    
    static func timeString(_ time: CGFloat) -> String {
        let mins = Int(time) / 60
        let secs = Int(time) % 60
        let milisecs = time - CGFloat(mins) * 60 - CGFloat(secs)
        return String(format: "%.2d:%.2d:%.3d", mins, secs, Int(milisecs * 1000))
    }
    
    static func showAlertView(error: Error? = nil, title: String? = nil, message: String? = nil, from viewController: UIViewController, cancel: String? = nil, _ okHandler: (() -> Void)? = nil) {
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            okHandler?()
        }
        var alertMessage = "There was a error. Please try again"
        var alertTitle = ""
        if let title = title {
            alertTitle = title
        }
        if let error = error {
            alertMessage = error.localizedDescription
            alertTitle = "Error"
        } else if let message = message {
            alertMessage = message
        }
        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        if let cancel = cancel {
            alertController.addAction(UIAlertAction(title: cancel, style: .cancel))
        }
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
