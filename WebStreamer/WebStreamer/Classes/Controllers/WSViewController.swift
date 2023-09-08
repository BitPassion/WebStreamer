//
//  WSViewController.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 8/2/22.
//

import UIKit
import SwiftyGif

class WSViewController: UIViewController {

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    deinit {
        if backgroundImageView != nil {
            backgroundImageView.gifImage = nil
            backgroundImageView.removeFromSuperview()
            backgroundImageView = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let gifBackground = gifBackground, backgroundImageView != nil {
            backgroundImageView.setGifImage(gifBackground)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleAppBecomeActive(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleAppEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func dismissToHome(_ viewController: UIViewController) {
        /*let controller = viewController.presentingViewController
        var isAnimated: Bool = false
        if controller is PlayViewController {
            isAnimated = true
        }

        viewController.dismiss(animated: isAnimated) {
            if let controller = controller, !(controller is PlayViewController) {
                if let viewController = viewController as? PlayViewController {
                    viewController.dismissToHome(controller)
                } else if let navigationController = viewController as? WSNavigationController {
                    navigationController.dismissToHome(viewController: controller)
                }
            }
        }*/
    }
    
    @objc func handleAppBecomeActive(_ notification: Notification) {
        if let gifBackground = gifBackground, backgroundImageView != nil {
            backgroundImageView.setGifImage(gifBackground)
        }
    }
    
    @objc func handleAppEnterBackground(_ notification: Notification) {
        if backgroundImageView != nil {
            backgroundImageView.gifImage = nil
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - IBAction
    @IBAction func actionOTA(_ sender: UIButton) {
        //let controller = self.presentingViewController
        let isAnimated = true
        //if controller is PlayViewController == false && controller is UINavigationController == false {
        //    isAnimated = false
        //}
        
        dismiss(animated: isAnimated) {
            //if controller != nil, !(controller is PlayViewController) {
            //    self.dismissToHome(controller!)
            //}
        }
    }

    @IBAction func actionBack(_ sender: Any) {
        if let navigationController = navigationController, navigationController.viewControllers.count >= 2 {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func actionSupport(_ sender: Any) {
        //var storyboard = UIStoryboard(name: "Main", bundle: nil)
        //if UIDevice.current.userInterfaceIdiom == .pad {
        //    storyboard = UIStoryboard(name: "Main_iPad", bundle: nil)
        //}
        
        /*let controller = storyboard.instantiateViewController(withIdentifier: "SupportViewController") as! SupportViewController
        controller.isFromSettings = true
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: true, completion: nil)*/
    }

    @IBAction func actionDownload(_ sender: Any) {
        actionBack(sender)
    }

    @IBAction func actionInfo(_ sender: Any) {
        UIApplication.shared.open(URL(string: "https://www.myosradio.app/helppics.html")!, options: [:], completionHandler: nil)
    }
}
