//
//  WSNavigationController.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 8/2/22.
//

import UIKit

class WSNavigationController: UINavigationController {

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        object_setClass(self.navigationBar, WSNavigationBar.self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        object_setClass(self.navigationBar, WSNavigationBar.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //self.additionalSafeAreaInsets.top = 48.0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func dismissToHome(viewController: UIViewController) {
        /*let controller = viewController.presentingViewController
        var isAnimated: Bool = false
        if controller is PlayViewController {
            isAnimated = true
        }
        
        viewController.dismiss(animated: isAnimated) {
            if let controller = controller, !(controller is PlayViewController) {
                if let viewController = viewController as? WSViewController {
                    viewController.dismissToHome(controller)
                } else if let navigationController = viewController as? WSNavigationController {
                    navigationController.dismissToHome(viewController: controller)
                }
            }
        }*/
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension UINavigationBar {
    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 164)
    }
}

class WSNavigationBar: UINavigationBar {
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 164)
    }
}
