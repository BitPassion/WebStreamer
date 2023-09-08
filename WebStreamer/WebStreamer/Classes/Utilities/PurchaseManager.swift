//
//  PurchaseVC.m
//  RandomMusicPlayer
//
//  Created by Yinjing Li on 10/3/20.
//  Copyright © 2020 Fredc Weber. All rights reserved.
//

import UIKit
import StoreKit
import SVProgressHUD

let UNLOCK_ALL_1MONTH =     "com.RandomMusic.app.1month"
let UNLOCK_ALL_6MONTH =     "com.RandomMusic.app.6month"
let UNLOCK_ALL_NOEXPIRE  =  "com.RandomMusic.com.noexpire"

@objc class PurchaseManager: NSObject {
    
    @objc var priceLocal: Locale?
    @objc var prices: [String: String] = [:]
    @objc var products: Set<SKProduct> = []
    @objc static let shared = PurchaseManager()
    
    let EXPIRE_DATE = "EXPIRE_DATE"
    let IS_PURCHASED = "IS_PURCHASED"
    let PRODUCT_ID = "PRODUCT_ID"
    
    @objc public func isPurchased(completion: @escaping (_ purchased: Bool) -> Void) {
        if UserDefaults.standard.object(forKey: IS_PURCHASED) != nil {
            if let expireDate = UserDefaults.standard.object(forKey: EXPIRE_DATE) as? Date, expireDate >= Date() {
                completion(UserDefaults.standard.bool(forKey: IS_PURCHASED))
            } else {
                let productId = UserDefaults.standard.string(forKey: PRODUCT_ID)
                verifySubscriptions([productId!], completion: completion)
            }
        } else {
            completion(false)
        }
    }
    
    @objc public func isAppAvailable() -> Bool {
        if isPurchased() {
            return true
        }
        
        var date = UserDefaults.standard.object(forKey: APP_DIDDOWNLOAD_INSTALLED) as? Date
        if date == nil {
            date = Date()
            UserDefaults.standard.setValue(date, forKey: APP_DIDDOWNLOAD_INSTALLED)
        }
        
        let interval = Date().timeIntervalSince(date!)
        if interval <= APP_EXPIRE_SECONDS {
            return true
        }
        return false
    }
    
    @objc public func isPurchased() -> Bool {
        if UserDefaults.standard.bool(forKey: UNLOCK_ALL_NOEXPIRE) == true {
            return true
        }
        
        if UserDefaults.standard.object(forKey: IS_PURCHASED) != nil {
            if let expireDate = UserDefaults.standard.object(forKey: EXPIRE_DATE) as? Date, expireDate >= Date() {
                //print(expireDate)
                return UserDefaults.standard.bool(forKey: IS_PURCHASED)
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    @objc public func isPurchased(productId: String) -> Bool {
        //return true
        if isPurchased() {
            return true
        }
        if UserDefaults.standard.object(forKey: productId) != nil {
            if let expireDate = UserDefaults.standard.object(forKey: EXPIRE_DATE) as? Date, expireDate >= Date() {
                return UserDefaults.standard.bool(forKey: IS_PURCHASED)
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    @objc public func isExpired() -> Bool {
        //return true
        if isPurchased() {
            return false
        }
        
        if UserDefaults.standard.bool(forKey: IS_PURCHASED) {
            if let expireDate = UserDefaults.standard.object(forKey: EXPIRE_DATE) as? Date, expireDate < Date() {
                return true
            }
        }
        
        return false
    }
    
    @objc public func verifyPurchase(_ productId: String, completion: () -> Void) {
        
    }
    
    @objc public func setPurchased(productId: String, purchased: Bool, expireDate: Date) {
        UserDefaults.standard.set(purchased, forKey: IS_PURCHASED)
        UserDefaults.standard.set(expireDate, forKey: EXPIRE_DATE)
        UserDefaults.standard.set(productId, forKey: PRODUCT_ID)
    }
    
    @objc public func removePurchase() {
        UserDefaults.standard.removeObject(forKey: IS_PURCHASED)
        UserDefaults.standard.removeObject(forKey: EXPIRE_DATE)
        UserDefaults.standard.removeObject(forKey: PRODUCT_ID)
    }

    @objc public func completeTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    self.updateSubscriptionStatus { (purchased) in
                        
                    }
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break
                }
            }
        }
    }
    
    @objc public func updateSubscriptionStatus(completion: @escaping (_ purchased: Bool) -> Void) {
        if UserDefaults.standard.bool(forKey: IS_PURCHASED) == false {
            completion(false)
            return
        }
        self.verifyReceipt { result in
            switch result {
            case .success(let receipt):
                let receipts = receipt["latest_receipt_info"]
                if let dict = receipts?.lastObject as? [String: Any], let prodictId = dict["product_id"] as? String {
                    let productIds = Set([prodictId].map { $0 })
                    let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
                    switch purchaseResult {
                    case .purchased(let expiryDate, _):
                        self.setPurchased(productId: productIds[productIds.startIndex], purchased: true, expireDate: expiryDate)
                        completion(true)
                    case .expired(let expiryDate, _):
                        self.setPurchased(productId: productIds[productIds.startIndex], purchased: true, expireDate: expiryDate)
                        completion(false)
                        break
                    case .notPurchased:
                        completion(false)
                        break
                    }
                }
                break
            case .error(let error):
                print("error on verification, \(error)")
                completion(false)
                break
            }
        }
    }
    
    @objc public func purchase(productId: String) {
        SwiftyStoreKit.purchaseProduct(productId, atomically: true) { result in
            SVProgressHUD.dismiss()
            if case .success(let purchase) = result {
                if purchase.productId == UNLOCK_ALL_1MONTH || purchase.productId == UNLOCK_ALL_6MONTH {
                    self.setPurchased(productId: purchase.productId, purchased: true, expireDate: Date().addingTimeInterval(4 * 60))
                } else if purchase.productId == UNLOCK_ALL_NOEXPIRE {
                    UserDefaults.standard.set(true, forKey: UNLOCK_ALL_NOEXPIRE)
                }
                NotificationCenter.default.post(name: .productPurchased, object: nil, userInfo: nil)
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                }
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                
                self.verifySubscriptions([productId], completion: {result in
                    
                })
            } else {
                print(result)
                NotificationCenter.default.post(name: .purchaseFailed, object: nil, userInfo: nil)
            }
            if let alert = self.alertForPurchaseResult(result) {
                self.showAlert(alert)
            }
        }
    }
    
    @objc public func restore() {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            SVProgressHUD.dismiss()
            var products: Set<String> = []
            for purchase in results.restoredPurchases {
                if purchase.productId == UNLOCK_ALL_1MONTH || purchase.productId == UNLOCK_ALL_6MONTH {
                    self.setPurchased(productId: purchase.productId, purchased: true, expireDate: Date().addingTimeInterval(10 * 60))
                } else {
                    UserDefaults.standard.set(true, forKey: purchase.productId)
                }
                
                products.insert(purchase.productId)
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                } else if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            
            if products.count > 0 {
                self.verifySubscriptions(products, completion: { (completed) in
                    if completed {
                        //NotificationCenter.default.post(name: .productPurchased, object: nil, userInfo: nil)
                    } else {
                        NotificationCenter.default.post(name: .productPurchased, object: nil, userInfo: nil)
                    }
                })
            } else {
                NotificationCenter.default.post(name: .purchaseFailed, object: nil, userInfo: nil)
            }
            
            self.showAlert(self.alertForRestorePurchases(results))
            if products.count > 0 {
                NotificationCenter.default.addObserver(self, selector: #selector(self.didCloseAlert), name: NSNotification.Name("alertDidClose"), object: nil)
            }
        }
    }
    
    @objc func didCloseAlert() {
        NotificationCenter.default.post(name: .productPurchased, object: nil, userInfo: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("alertDidClose"), object: nil)
    }
    
    func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "c7e66290fb5f46aa998c66a209defc46")
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
    }
    
    func verifySubscriptions(_ purchases: Set<String>, completion: @escaping (Bool) -> Void) {
        if UserDefaults.standard.bool(forKey: IS_PURCHASED) == false {
            return
        }
        verifyReceipt { result in
            switch result {
            case .success(let receipt):
                let productIds = Set(purchases.map { $0 })
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
                switch purchaseResult {
                case .purchased(let expiryDate, _):
                    self.setPurchased(productId: productIds[productIds.startIndex], purchased: true, expireDate: expiryDate)
                    completion(true)
                case .expired(let expiryDate, _):
                    self.setPurchased(productId: productIds[productIds.startIndex], purchased: false, expireDate: expiryDate)
                    completion(false)
                    break
                case .notPurchased:
                    completion(false)
                    break
                }
                //self.showAlert(self.alertForVerifySubscriptions(purchaseResult, productIds: productIds))
                break
            case .error:
                completion(false)
                //self.showAlert(self.alertForVerifyReceipt(result))
                break
            }
        }
    }
    
    @objc public func retrievePrices(productIds: Set<String>, completion: @escaping ([String : String]) -> Void) {
        var products: [String : String] = [:]
        SwiftyStoreKit.retrieveProductsInfo(productIds) {[weak self] (results) in
            //print(results.invalidProductIDs)
            for result in results.retrievedProducts {
                self?.priceLocal = result.priceLocale
                products[result.productIdentifier] = result.localizedPrice!
            }
            PurchaseManager.shared.products = results.retrievedProducts
            PurchaseManager.shared.prices = products
            completion(products)
        }
    }
    
    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
        switch result {
        case .success(let purchase):
            print("Purchase Success: \(purchase.productId)")
            return nil
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case .unknown: return alertWithTitle("Purchase failed", message: "There is a problem connecting to the App Store, please try again")
            case .clientInvalid: // client is not allowed to issue the request, etc.
                return alertWithTitle("Purchase failed", message: "Not allowed to make the payment")
            case .paymentCancelled: // user cancelled the request, etc.
                return nil
            case .paymentInvalid: // purchase identifier was invalid, etc.
                return alertWithTitle("Purchase failed", message: "The purchase identifier was invalid")
            case .paymentNotAllowed: // this device is not allowed to make the payment
                return alertWithTitle("Purchase failed", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable: // Product is not available in the current storefront
                return alertWithTitle("Purchase failed", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                return alertWithTitle("Purchase failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                return alertWithTitle("Purchase failed", message: "Could not connect to the network")
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                return alertWithTitle("Purchase failed", message: "Cloud service was revoked")
            default:
                return alertWithTitle("Purchase failed", message: "Unknown error was occurred")
            }
        }
    }
    
    func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {
        
        if results.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(results.restoreFailedPurchases)")
            return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
        } else if results.restoredPurchases.count > 0 {
            print("Restore Success: \(results.restoredPurchases)")
            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
        } else {
            print("Nothing to Restore")
            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
        }
    }
    
    func alertForVerifySubscriptions(_ result: VerifySubscriptionResult, productIds: Set<String>) -> UIAlertController {
        
        switch result {
        case .purchased(let expiryDate, let items):
            print("\(productIds) is valid until \(expiryDate)\n\(items)\n")
            return alertWithTitle("Product is purchased", message: "Product is valid until \(expiryDate)")
        case .expired(let expiryDate, let items):
            print("\(productIds) is expired since \(expiryDate)\n\(items)\n")
            return alertWithTitle("Product expired", message: "Product is expired since \(expiryDate)")
        case .notPurchased:
            print("\(productIds) has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
    
    func alertForVerifyPurchase(_ result: VerifyPurchaseResult, productId: String) -> UIAlertController {
        
        switch result {
        case .purchased:
            print("\(productId) is purchased")
            return alertWithTitle("Product is purchased", message: "Product will not expire")
        case .notPurchased:
            print("\(productId) has never been purchased")
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }
    
    func alertForVerifyReceipt(_ result: VerifyReceiptResult) -> UIAlertController {
        
        switch result {
        case .success(let receipt):
            print("Verify receipt Success: \(receipt)")
            return alertWithTitle("Receipt verified", message: "Receipt verified remotely")
        case .error(let error):
            print("Verify receipt Failed: \(error)")
            switch error {
            case .noReceiptData:
                return alertWithTitle("Receipt verification", message: "No receipt data. Try again.")
            case .networkError:
                return alertWithTitle("Receipt verification", message: "Network error while verifying receipt: There is a problem connecting to the App Store, please try again")
            default:
                return alertWithTitle("Receipt verification", message: "Receipt verification failed: There is a problem connecting to the App Store, please try again")
            }
        }
    }
    
    func showAlert(_ alert: UIAlertController, _ completion: (() -> Void)? = nil) {
        if let viewController = topViewController {
            DispatchQueue.main.async {
                viewController.present(alert, animated: true, completion: completion)
            }
        }
    }
    var topViewController: UIViewController? {
        return UIApplication.topViewController()
    }
    
    func alertWithTitle(_ title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {_ in
            NotificationCenter.default.post(name: NSNotification.Name("alertDidClose"), object: nil, userInfo: nil)
        }))
        return alert
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.windows.filter { $0.isKeyWindow }.first?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
    
    class func keyWindow() -> UIWindow? {
        return UIApplication.shared.windows.filter{ $0.isKeyWindow }.first
    }
}
