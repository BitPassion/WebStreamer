//
//  BrowserViewController.swift
//  WebStreamer
//
//  Created by Yinjing Li on 8/2/23.
//

import UIKit
import WebKit
import AVKit

class BrowserViewController: WSViewController {

    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var liveStreamSwitch: UISwitch!
    @IBOutlet weak var webContentsView: WKWebView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var animationView: UIView!
    
    @IBOutlet weak var topTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomBottomConstraint: NSLayoutConstraint!
    
    fileprivate var webView: WKWebView!
    fileprivate var webBottomView: WebBottomView!
    fileprivate var isTabBarShowed: Bool = true
    
    fileprivate var playerViewControllers: [AVPlayerViewController] = []
    fileprivate var addTime: Date = Date()
    fileprivate var presentedWindows: [UIViewController: UIWindow] = [:]
    fileprivate var keyWindows: [UIWindow: UIWindow] = [:]
    
    var url: LiveURL!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        webBottomView.tabs = LiveURLManager.shared.urls.count
        
        liveStreamSwitch.isOn = LiveStreamManager.shared.isStreaming
        
        checkBookmarkStatus()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        saveBrowser()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startAnimation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webBottomView.frame = bottomView.bounds
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { context in
            self.layoutView()
        } completion: { context in
            
        }
    }
    
    fileprivate func initView() {
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        
        let viewportScript = """
                var viewport = document.querySelector("meta[name=viewport]");
                viewport.setAttribute('content', 'width=device-width, initial-scale=1.0, minimum-scale=0.1, maximum-scale=4.0, user-scalable=0');
            """
        let script = WKUserScript(source: viewportScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = .all
        //configuration.suppressesIncrementalRendering = false
        //configuration.allowsPictureInPictureMediaPlayback = false
        //configuration.allowsAirPlayForMediaPlayback = false
        configuration.preferences = preferences
        configuration.userContentController.addUserScript(script)
        webView = WKWebView(frame: UIScreen.main.bounds, configuration: configuration)
        webContentsView.addSubview(webView)
        
        webView.scrollView.delegate = self
        webView.scrollView.contentInset = .zero
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        
        //let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        //gestureRecognizer.delegate = self
        //webView.addGestureRecognizer(gestureRecognizer)
        
        loadURL()
        
        webBottomView = WebBottomView.loadFromNib()
        webBottomView.frame = webBottomView.bounds
        webBottomView.autoresizingMask = [.flexibleTopMargin, .flexibleLeftMargin, .flexibleBottomMargin, .flexibleRightMargin, .flexibleWidth, .flexibleHeight]
        webBottomView.delegate = self
        bottomView.addSubview(webBottomView)
        
        updateWebBottomButtons()
        
        let imageSize = Utilities.isPhone ? CGSize(width: 18.0, height: 18.0) : CGSize(width: 26.0, height: 26.0)
        bookmarkButton.setImage(UIImage.svgImage(named: "bookmark", color: .black, size: imageSize), for: .normal)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerFullscreen(_:)), name: UIWindow.didBecomeVisibleNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerDidHidden(_:)), name: UIWindow.didBecomeHiddenNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerWillAppear(_:)), name: .videoPlayerWillAppear, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerWillDisappear(_:)), name: .videoPlayerWillDisappear, object: nil)
    }
    
    fileprivate func layoutView() {
        var frame = urlView.frame
        frame.size.width = UIScreen.main.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right - 120.0
        frame.origin.x = (UIScreen.main.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right - frame.width) / 2.0
        urlView.frame = frame
    }
    
    fileprivate func loadURL() {
        if let url = URL(string: self.url.url) {
            webView.load(URLRequest(url: url))
        }
        
        urlTextField.text = url.url
        
        updateWebBottomButtons()
        
        NotificationCenter.default.post(name: .browserChanged, object: nil)
    }
    
    fileprivate func saveBrowser() {
        let image = webView.render()
        let data = image.jpegData(compressionQuality: 1.0)
        try? data?.write(to: url.thumbURL)
    }
    
    fileprivate func updateWebBottomButtons() {
        if webBottomView != nil {
            webBottomView.canGoBack = webView.canGoBack
            webBottomView.canGoForward = webView.canGoForward
        }
    }
    
    fileprivate func startAnimation() {
        animationView.layer.removeAllAnimations()
        
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
        animationView.layer.add(animationGroup, forKey: "animation")
    }
    
    fileprivate func checkBookmarkStatus() {
        let imageSize = Utilities.isPhone ? CGSize(width: 18.0, height: 18.0) : CGSize(width: 26.0, height: 26.0)
        if let url = webView.url {
            if BookmarkManager.shared.isBookmarked(url.absoluteString) {
                bookmarkButton.setImage(UIImage.svgImage(named: "bookmark-select", color: .black, size: imageSize), for: .normal)
            } else {
                bookmarkButton.setImage(UIImage.svgImage(named: "bookmark", color: .black, size: imageSize), for: .normal)
            }
        } else {
            bookmarkButton.setImage(UIImage.svgImage(named: "bookmark", color: .black, size: imageSize), for: .normal)
        }
    }
    
    @objc fileprivate func handleTapGestureRecognizer(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            if self.isTabBarShowed {
                self.topTopConstraint.constant = -self.topView.frame.height
                self.topView.alpha = 0.0
                self.bottomBottomConstraint.constant = -self.bottomView.frame.height
                self.bottomView.alpha = 0.0
                if Utilities.isPhone {
                    self.expandButton.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 17.0))), for: .normal)
                } else {
                    self.expandButton.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left", withConfiguration: UIImage.SymbolConfiguration(font: .custom(size: 20.0, weight: .semiBold)!)), for: .normal)
                }
            } else {
                self.topTopConstraint.constant = 0.0
                self.topView.alpha = 1.0
                self.bottomBottomConstraint.constant = 0
                self.bottomView.alpha = 1.0
                if Utilities.isPhone {
                    self.expandButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 17.0))), for: .normal)
                } else {
                    self.expandButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: UIImage.SymbolConfiguration(font: .custom(size: 20.0, weight: .semiBold)!)), for: .normal)
                }
            }
            self.isTabBarShowed = !self.isTabBarShowed
            self.view.layoutIfNeeded()
        }
    }

    @objc fileprivate func handlePlayerTapGestureRecognizer(_ sender: Any) {
        
    }
    
    @objc fileprivate func handlePlayerFullscreen(_ notification: NSNotification) {
        if let window = notification.object as? UIWindow {//, window.description.contains("PGHostedWindow") {
            /*ScreenRecorder.shared.stop { success in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    ScreenRecorder.shared.start { success, error in

                    }
                }
            }*/
            print(window)
            if let controller = window.rootViewController {
                print(controller)
                presentedWindows[controller] = window
            }
            if let keyWindow = UIApplication.keyWindow() {
                keyWindows[window] = keyWindow
            }
            //if let keyWindow = UIApplication.keyWindow() {
            //    print(keyWindow)
            //    keyWindow.addSubview(window)
            //}
            //liveStreamSwitch.isOn = true
            //didChangeLiveStream(liveStreamSwitch)
        }
    }
    
    @objc fileprivate func handlePlayerDidHidden(_ notification: NSNotification) {
        if let window = notification.object as? UIWindow, window.description.contains("PGHostedWindow") {
            print(window)
        }
    }
    
    @objc fileprivate func handlePlayerWillAppear(_ notification: NSNotification) {
        //print(notification)
        if let playerViewController = notification.object as? AVPlayerViewController, playerViewControllers.contains(playerViewController) == false {
            //playerViewController.delegate = self
            addTime = Date()
            if let controller = playerViewController.parent {
                controller.dismiss(animated: false) {
                    self.present(controller, animated: false) {
                        let viewController = controller
                        print(viewController)
                        self.playerViewControllers.append(playerViewController)
                        if let keyWindow = UIApplication.keyWindow() {
                            keyWindow.isHidden = true
                            keyWindow.rootViewController?.dismiss(animated: true)
                        }
                    }
                }
            } else {
                playerViewController.dismiss(animated: false) {
                    self.present(playerViewController, animated: false) {
                        self.playerViewControllers.append(playerViewController)
                        if let keyWindow = UIApplication.keyWindow() {
                            keyWindow.isHidden = true
                            keyWindow.rootViewController?.dismiss(animated: true)
                        }
                    }
                }
            }
        } else {

        }
    }
    
    @objc fileprivate func handlePlayerWillDisappear(_ notification: NSNotification) {
        print(notification)
        let seconds = Date().timeIntervalSince(addTime)
        if let playerViewController = notification.object as? AVPlayerViewController, seconds >= 2.0 {
            if let index = playerViewControllers.firstIndex(of: playerViewController) {
                playerViewControllers.remove(at: index)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.presentedViewController?.dismiss(animated: true)
            }
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
    override func actionBack(_ sender: Any) {
        webView.stopLoading()
        if #available(iOS 15.0, *) {
            webView.pauseAllMediaPlayback()
        } else {
            // Fallback on earlier versions
        }
        webView.removeFromSuperview()
        
        super.actionBack(sender)
    }
    
    @IBAction func didTapExpand(_ sender: Any) {
        handleTapGestureRecognizer(sender)
    }
    
    @IBAction func didTapRefresh(_ sender: UIButton) {
        webView.reload()
    }
    
    @IBAction func didTapHome(_ sender: UIButton) {
        
    }
    
    @IBAction func didTapTabs(_ sender: UIButton) {
        
    }
    
    @IBAction func didChangeLiveStream(_ sender: UISwitch) {
        /*guard let connection = LiveStreamManager.shared.connection(with: url.connectionId) else {
            sender.isOn = false
            Utilities.showAlertView(error: nil, title: APP_NAME, message: "Please add RTMP Stream connections on settings screen.", from: self) {
                let controller = self.storyboard!.instantiateViewController(withIdentifier: "NewConnectionViewController") as! NewConnectionViewController
                controller.delegate = self
                self.navigationController?.pushViewController(controller, animated: true)
            }
            return
        }
        LiveStreamManager.shared.currentConnection = connection
        LiveStreamManager.shared.updateConnection(connection)
        */
        if sender.isOn {
            ScreenRecorder.shared.start { success, error in
                DispatchQueue.main.async {
                    if success == true {
                        LiveStreamManager.shared.start()
                    } else {
                        sender.isOn = false
                        LiveStreamManager.shared.stop()
                        Utilities.showAlertView(error: error, title: "Error", message: "There was a error. Please try again.", from: self, nil)
                    }
                }
            }
        } else {
            LiveStreamManager.shared.stop()
            ScreenRecorder.shared.stop { success in
                print(success)
            }
        }
        
        LiveStreamManager.shared.didUpdateStatus = { status in
            DispatchQueue.main.async {
                print("+++++++++++++ \(status.rawValue) +++++++++++++")
                if LiveStreamManager.shared.isStreaming == true {
                    if status == .connectSuccess {
                        self.liveStreamSwitch.isOn = true
                    } else {
                        if self.liveStreamSwitch.isOn {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                                LiveStreamManager.shared.start()
                            }
                        } else {
                            self.liveStreamSwitch.isOn = false
                            LiveStreamManager.shared.stop(isDisconnected: true)
                            ScreenRecorder.shared.stop { success in
                                print(success)
                            }
                            //if status == .connectFailed || status == .connectRejected {
                                let controller = UIAlertController(title: "Error", message: "Streaming has been stopped. Code: \(status.rawValue).", preferredStyle: .alert)
                                controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in

                                }))
                                self.present(controller, animated: true, completion: nil)
                            //}
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func didTapBookmark(_ sender: Any) {
        if let url = webView.url {
            if BookmarkManager.shared.isBookmarked(url.absoluteString) == false {
                let bookmark = Bookmark(name: "", url: url.absoluteString)
                BookmarkManager.shared.saveBookmark(bookmark)
            } else {
                BookmarkManager.shared.removeBookmark(url.absoluteString)
            }
            checkBookmarkStatus()
        }
    }
}

// MARK: - WebBottomViewDelegate
extension BrowserViewController: WebBottomViewDelegate {
    func didTapWebBottom(_ item: WebBottomViewItem) {
        switch item {
        case .back:
            webView.goBack()
        case .forward:
            webView.goForward()
        case .share:
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "NewConnectionViewController") as! NewConnectionViewController
            if let connection = LiveStreamManager.shared.connection(with: url.connectionId) {
                controller.connection = connection
            }
            controller.delegate = self
            self.navigationController?.pushViewController(controller, animated: true)
        case .home:
            TabBarViewController.current.selectedIndex = 0
            actionBack(item)
        case .tabs:
            let navigationController = self.storyboard!.instantiateViewController(withIdentifier: "TabsNavigationController") as! UINavigationController
            navigationController.modalPresentationStyle = .fullScreen
            if let controller = navigationController.viewControllers.first as? TabsViewController {
                controller.showsBackButton = true
                controller.isFromBrowser = true
                controller.delegate = self
                controller.selectedURL = url
            }
            present(navigationController, animated: true)
        }
    }
}

// MARK: - TabsViewControllerDelegate
extension BrowserViewController: TabsViewControllerDelegate {
    func didSelectLiveURL(_ url: LiveURL) {
        if self.url.id == url.id {
            return
        }
        self.url = url
        loadURL()
    }
}

// MARK: - UITextFieldDelegate
extension BrowserViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if var text = textField.text, text != "" {
            let prefix = String(text.prefix(10))
            if !prefix.contains("http://") && !prefix.contains("https://") {
                text = "https://" + text
            }
            if let url = URL(string: text), UIApplication.shared.canOpenURL(url) {
                self.url.url = text
                loadURL()
            } else {
                Utilities.showAlertView(error: nil, title: "Error", message: "Please input valid url", from: self, nil)
            }
        } else {
            Utilities.showAlertView(error: nil, title: "Error", message: "Please input valid url", from: self, nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - WKNavigationDelegate
extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        updateWebBottomButtons()
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        updateWebBottomButtons()
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        updateWebBottomButtons()
        decisionHandler(.allow, preferences)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateWebBottomButtons()
        if let url = webView.url {
            urlTextField.text = url.absoluteString
            checkBookmarkStatus()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateWebBottomButtons()
    }
}

// MARK: - NewConnectionViewControllerDelegate
extension BrowserViewController: NewConnectionViewControllerDelegate {
    func didSaveConnection(_ connection: LiveStream) {
        if url.connectionId == "" {
            url.connectionId = connection.id
            LiveURLManager.shared.saveURL(url)
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension BrowserViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIControl {
            return false
        }
        
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

// MARK: - UIScrollViewDelegate
extension BrowserViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isTabBarShowed {
            handleTapGestureRecognizer(scrollView)
        }
    }
}

// MARK: - UIScrollViewDelegate
extension BrowserViewController: WKUIDelegate {
    func webViewDidClose(_ webView: WKWebView) {
        
    }
}
