//
//  TabBarViewController.swift
//  WebStreamer
//
//  Created by Yinjing Li on 8/1/23.
//

import UIKit
import AVKit

class TabBarViewController: UIViewController {

    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var animationView: UIView!
    
    @IBOutlet weak var bottomTabBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightTabBarConstraint: NSLayoutConstraint!
    
    private(set) lazy var tabBarView: TabBarView = {
        return TabBarView.loadFromNib()
    }()
    
    static var current: TabBarViewController!
    
    fileprivate var audioPlayer: AVAudioPlayer? = nil
    
    var isTabBarHidden: Bool {
        return bottomTabBarConstraint.constant != 0.0
    }

    var selectedIndex: Int = 0 {
        didSet {
            tabBarView.selectedIndex = selectedIndex
            for view in self.view.subviews {
                if view.tag >= 10 {
                    if view.tag - 10 == selectedIndex {
                        view.isHidden = false
                    } else {
                        view.isHidden = true
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        TabBarViewController.current = self
        
        initView()
        
        initAudioSession()
        
        //playSong()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarView.tabs = LiveURLManager.shared.urls.count
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tabBarView.frame = bottomView.bounds
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate { context in
            let orientation = UIApplication.orientation()
            self.tabBarView.orientation = orientation
        } completion: { context in
            ScreenRecorder.shared.orientation = UIApplication.orientation()
        }
    }
    
    fileprivate func initView() {
        if Utilities.isPad {
            heightTabBarConstraint.constant = 80.0
        }
        
        tabBarView.frame = bottomView.bounds
        bottomView.addSubview(tabBarView)
        tabBarView.delegate = self
        tabBarView.selectedIndex = TabBarIndex.home.rawValue
        
        updateTabs()
        
        animationView.addAnimation()
    }
    
    fileprivate func initAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord)
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker, .allowAirPlay, .allowBluetooth, .allowBluetoothA2DP, .duckOthers, .mixWithOthers, .interruptSpokenAudioAndMixWithOthers])
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            //print(error)
        }
    }
    
    fileprivate func playSong() {
        if let url = Bundle.main.url(forResource: "Emily Ann Roberts - Wild", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
            } catch {
                print(error.localizedDescription)
            }
        }
        audioPlayer?.delegate = self
        audioPlayer?.play()
    }
    
    fileprivate func stopSong() {
        audioPlayer?.stop()
    }
    
    // MARK: - Public Methods
    func updateTabs() {
        tabBarView.tabs = LiveURLManager.shared.urls.count
    }
    
    func setTabBarHidden(_ isHidden: Bool, _ animated: Bool = false) {
        let duration: CGFloat = animated ? 0.3 : 0.0
        UIView.animate(withDuration: duration) {
            if isHidden {
                self.bottomTabBarConstraint.constant = -self.bottomView.frame.height
                self.bottomView.alpha = 0.0
            } else {
                self.bottomTabBarConstraint.constant = 0.0
                self.bottomView.alpha = 1.0
            }
            self.view.layoutIfNeeded()
        } completion: { finished in
            
        }
    }

    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "BrowserNavigationController" {
            let navigationController = segue.destination as! UINavigationController
            navigationController.modalPresentationStyle = .fullScreen
            let controller = navigationController.viewControllers[0] as! BrowserViewController
            controller.url = (sender as! LiveURL)
        } else if segue.identifier == "BrowserViewController" {
            let controller = segue.destination as! BrowserViewController
            controller.url = (sender as! LiveURL)
        }
    }
}

// MARK: - TabBarViewDelegate
extension TabBarViewController: TabBarViewDelegate {
    func didSelectTabBar(_ index: TabBarIndex) {
        self.selectedIndex = index.rawValue
    }
}

// MARK: - AVAudioPlayerDelegate
extension TabBarViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.currentTime = 0.0
        player.play()
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        player.currentTime = 0.0
        player.play()
    }
}
