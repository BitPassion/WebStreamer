//
//  HomeViewController.swift
//  WebStreamer
//
//  Created by Yinjing Li on 8/1/23.
//

import UIKit
import WebKit
import AVKit
import ReplayKit

class HomeViewController: WSViewController {

    @IBOutlet weak var expandButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var bookmarkButton: UIButton!
    @IBOutlet weak var liveStreamSwitch: UISwitch!
    @IBOutlet weak var webContentsView: WKWebView!
    
    @IBOutlet weak var topTopConstraint: NSLayoutConstraint!
    
    fileprivate var webView: WKWebView!
    
    fileprivate var player: AVPlayer!
    fileprivate var playerViewControllers: [AVPlayerViewController] = []
    fileprivate var addTime: Date = Date()
    fileprivate var presentedWindows: [UIViewController: UIWindow] = [:]
    fileprivate var keyWindows: [UIWindow: UIWindow] = [:]
    
    fileprivate var isTabBarShowed: Bool = true
    fileprivate var isFirstAppear: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initView()
        
        layoutView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if isFirstAppear {
            isFirstAppear = false
            loadCurrentURL()
            
            checkBookmarkStatus()
        }
        
        liveStreamSwitch.isOn = LiveStreamManager.shared.isStreaming
        
        SwizzlingManager.shared.startSwizzling()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SwizzlingManager.shared.stopSwizzling()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        webView.frame = webContentsView.bounds
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
        webView.scrollView.automaticallyAdjustsScrollIndicatorInsets = false
        
        //let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer(_:)))
        //gestureRecognizer.delegate = self
        //webView.addGestureRecognizer(gestureRecognizer)
        
        let imageSize: CGSize = Utilities.isPhone ? CGSize(width: 28.0, height: 28.0) : CGSize(width: 36.0, height: 36.0)
        bookmarkButton.setImage(UIImage.svgImage(named: "bookmark", color: .black, size: imageSize), for: .normal)
        backwardButton.setImage(UIImage.svgImage(named: "arrow-left", color: .label, size: imageSize), for: .normal)
        backwardButton.setImage(UIImage.svgImage(named: "arrow-left", color: .lightGray, size: imageSize), for: .disabled)
        forwardButton.setImage(UIImage.svgImage(named: "arrow-right", color: .label, size: imageSize), for: .normal)
        forwardButton.setImage(UIImage.svgImage(named: "arrow-right", color: .lightGray, size: imageSize), for: .disabled)
        //refreshButton.setImage(UIImage.svgImage(named: "rotate-left", color: .label, size: imageSize), for: .normal)
        //refreshButton.setImage(UIImage.svgImage(named: "rotate-left", color: .lightGray, size: imageSize), for: .disabled)
        refreshButton.tintColor = .label
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBrowserChanged(_:)), name: .browserChanged, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerFullscreen(_:)), name: UIWindow.didBecomeVisibleNotification, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerDidHidden(_:)), name: UIWindow.didBecomeHiddenNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerWillAppear(_:)), name: .videoPlayerWillAppear, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerWillDisappear(_:)), name: .videoPlayerWillDisappear, object: nil)
    }
    
    fileprivate func layoutView() {
        //var frame = urlView.frame
        //frame.size.width = UIScreen.main.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right - 120.0
        //frame.origin.x = (UIScreen.main.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right - frame.width) / 2.0
        //urlView.frame = frame
    }
    
    fileprivate func loadCurrentURL() {
        if let liveURL = LiveURLManager.shared.currentURL, let url = URL(string: liveURL.url) {
            let request = URLRequest(url: url)
            webView.load(request)
            urlTextField.text = liveURL.url
            checkBookmarkStatus()
        } else {
            let url = "https://osp2.montanasat.net/view/eaed25bc-037f-4a7e-a054-8d659fd345e3/"
            let request = URLRequest(url: URL(string: url)!)
            webView.load(request)
            urlTextField.text = url
            checkBookmarkStatus()
        }
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
    
    fileprivate func playVideo() {
        let url = Bundle.main.url(forResource: "8948", withExtension: "mp4")!
        player = AVPlayer(url: url)
        let controller = AVPlayerViewController()
        controller.player = player
        present(controller, animated: true) {
            self.player.play()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerDidEndTime(_:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    fileprivate func updateWebOperationButtons() {
        print(webView.canGoBack)
        backwardButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
    }
    
    @objc fileprivate func handleTapGestureRecognizer(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            if self.isTabBarShowed {
                self.topTopConstraint.constant = -self.topView.frame.height
                self.topView.alpha = 0.0
                if Utilities.isPhone {
                    self.expandButton.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 17.0))), for: .normal)
                } else {
                    self.expandButton.setImage(UIImage(systemName: "arrow.down.right.and.arrow.up.left", withConfiguration: UIImage.SymbolConfiguration(font: .custom(size: 20.0, weight: .semiBold)!)), for: .normal)
                }
            } else {
                self.topTopConstraint.constant = 0.0
                self.topView.alpha = 1.0
                if Utilities.isPhone {
                    self.expandButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 17.0))), for: .normal)
                } else {
                    self.expandButton.setImage(UIImage(systemName: "arrow.up.left.and.arrow.down.right", withConfiguration: UIImage.SymbolConfiguration(font: .custom(size: 20.0, weight: .semiBold)!)), for: .normal)
                }
            }
            self.isTabBarShowed = !self.isTabBarShowed
            self.view.layoutIfNeeded()
        }
        TabBarViewController.current.setTabBarHidden(!self.isTabBarShowed, true)
    }
    
    @objc fileprivate func handleBrowserChanged(_ notification: NSNotification) {
        loadCurrentURL()
    }
    
    @objc fileprivate func handlePlayerTapGestureRecognizer(_ sender: Any) {
        
    }
    
    @objc fileprivate func handlePlayerDidEndTime(_ notification: NSNotification) {
        if let player = self.player {
            player.seek(to: .zero)
            player.play()
        }
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
                            print(playerViewController.player ?? "AVPlayerViewController is null")
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
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "NewConnectionViewController" {
            let controller = segue.destination as! NewConnectionViewController
            if let liveURL = LiveURLManager.shared.currentURL, let connection = LiveStreamManager.shared.connection(with: liveURL.connectionId) {
                controller.connection = connection
            }
        }
    }

    // MARK: - IBAction
    @IBAction func didTapBackward(_ sender: UIButton) {
        webView.goBack()
    }
    
    @IBAction func didTapForward(_ sender: UIButton) {
        webView.goForward()
    }
    
    @IBAction func didTapRefresh(_ sender: UIButton) {
        webView.reload()
    }
    
    @IBAction func didTapExpand(_ sender: Any) {
        handleTapGestureRecognizer(sender)
    }
    
    @IBAction func didTapSettings(_ sender: Any) {
        //performSegue(withIdentifier: "NewConnectionViewController", sender: nil)
        performSegue(withIdentifier: "ConnectionsViewController", sender: nil)
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
    
    @IBAction func didChangeLiveStream(_ sender: UISwitch) {
        if LiveStreamManager.shared.connections.count == 0 || LiveStreamManager.shared.currentConnectionIndex == -1 {
            sender.isOn = false
            Utilities.showAlertView(error: nil, title: APP_NAME, message: "Please add RTMP Stream connections on settings screen.", from: self, nil)
            return
        }
        if sender.isOn {
            ScreenRecorder.shared.start { success, error in
                DispatchQueue.main.async {
                    if success == true {
                        LiveStreamManager.shared.start()
                        //self.playVideo()
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
        /*RPBroadcastActivityViewController.load { controller, error in
            guard error == nil else {
                print("Cannot load Broadcast Activity View Controller.")
                return
            }
            
            //3
            if let controller = controller {
                //controller.delegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }*/
    }
}

// MARK: - UITextFieldDelegate
extension HomeViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, let url = URL(string: text) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        layoutView()
        return true
    }
}

// MARK: - WKNavigationDelegate
extension HomeViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("================================")
        print(navigationAction.request.url ?? "")
        updateWebOperationButtons()
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        print("++++++++++++++++++++++++++++++++")
        print(navigationAction.request.url ?? "")
        updateWebOperationButtons()
        decisionHandler(.allow, preferences)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        updateWebOperationButtons()
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateWebOperationButtons()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //SVProgressHUD.dismiss()
        updateWebOperationButtons()
        if let url = webView.url {
            urlTextField.text = url.absoluteString
            checkBookmarkStatus()
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        //SVProgressHUD.dismiss()
        updateWebOperationButtons()
        print(navigation!)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension HomeViewController: UIGestureRecognizerDelegate {
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

// MARK: - AVPlayerViewControllerDelegate
extension HomeViewController: AVPlayerViewControllerDelegate {
    func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        print("willBeginFullScreenPresentationWithAnimationCoordinator")
    }

    func playerViewController(_ playerViewController: AVPlayerViewController, willEndFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        print("willEndFullScreenPresentationWithAnimationCoordinator")
        if let controller = playerViewController.parent, let window = presentedWindows[controller], let keyWindow = keyWindows[window] {
            //window.isHidden = false
            //keyWindow.isHidden = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                keyWindow.becomeFirstResponder()
            }
        }
    }

    func playerViewController(_ playerViewController: AVPlayerViewController, restoreUserInterfaceForFullScreenExitWithCompletionHandler completionHandler: @escaping (Bool) -> Void) {
        print("restoreUserInterfaceForFullScreenExitWithCompletionHandler")
    }

    @available(iOS 16.0, *)
    func playerViewController(_ playerViewController: AVPlayerViewController, willPresent interstitial: AVInterstitialTimeRange) {
        print("interstitial")
    }

    @available(iOS 16.0, *)
    func playerViewController(_ playerViewController: AVPlayerViewController, didPresent interstitial: AVInterstitialTimeRange) {
        print("didPresent")
    }
}

// MARK: - UIScrollViewDelegate
extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isTabBarShowed {
            handleTapGestureRecognizer(scrollView)
        }
    }
}
