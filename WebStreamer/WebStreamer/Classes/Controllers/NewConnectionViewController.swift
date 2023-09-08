//
//  NewConnectionViewController.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 5/22/23.
//

import UIKit
import Foundation

protocol NewConnectionViewControllerDelegate {
    func didSaveConnection(_ connection: LiveStream)
}

class NewConnectionViewController: WSViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    //@IBOutlet weak var urlTextView: UITextView!
    @IBOutlet weak var urlTextField: UITextField!
    //@IBOutlet weak var keyTextView: UITextView!
    @IBOutlet weak var keyTextField: UITextField!
    @IBOutlet weak var modeTextField: UITextField!
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var targetTypeTextField: UITextField!
    @IBOutlet weak var targetTypeButton: UIButton!
    @IBOutlet weak var audioBitrateTextField: UITextField!
    @IBOutlet weak var audioBitrateButton: UIButton!
    @IBOutlet weak var videoBitrateTextField: UITextField!
    @IBOutlet weak var videoBitrateButton: UIButton!
    @IBOutlet weak var frameRateTextField: UITextField!
    @IBOutlet weak var frameRateButton: UIButton!
    @IBOutlet weak var loginTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var connection: LiveStream = .init(name: "", url: "", key: "", mode: .audioVideo, targetType: .default, audioBitrate: .bps320, videoBitrate: .bps2500, frameRate: .fps30, login: "", password: "")
    var delegate: NewConnectionViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // For test
        initView()
        
        //nameTextField.text = "Osp2"
        //urlTextField.text = "rtmp://osp2.montanasat.net/stream"
        //keyTextField.text = "77b61199-6187-430b-8293-3a39f4b36378"
        //connection.name = nameTextField.text ?? ""
        //connection.url = urlTextField.text ?? ""
        //connection.key = keyTextField.text ?? ""
    }
    
    fileprivate func initView() {
        nameTextField.text = connection.name
        urlTextField.text = connection.url
        keyTextField.text = connection.key
        modeButton.setTitle(connection.mode.title, for: .normal)
        targetTypeButton.setTitle(connection.targetType.title, for: .normal)
        audioBitrateButton.setTitle(connection.audioBitrate.title, for: .normal)
        frameRateButton.setTitle(connection.frameRate.title, for: .normal)
        loginTextField.text = connection.login
        passwordTextField.text = connection.password
    }
    
    fileprivate func showModes(_ sender: UIView) {
        let menuItems = [
            YJLActionMenuItem(LiveStreamMode.audioVideo.title, image: nil, target: self, action: #selector(selectStreamingMode(_:)), value: CGFloat(LiveStreamMode.audioVideo.rawValue)),
            YJLActionMenuItem(LiveStreamMode.video.title, image: nil, target: self, action: #selector(selectStreamingMode(_:)), value: CGFloat(LiveStreamMode.video.rawValue)),
            YJLActionMenuItem(LiveStreamMode.audio.title, image: nil, target: self, action: #selector(selectStreamingMode(_:)), value: CGFloat(LiveStreamMode.audio.rawValue)),
        ]

        let frame = sender.convert(sender.bounds, to: self.view)
        YJLActionMenu.show(in: self.view, from: frame, menuItems: menuItems as [Any], isWhiteBG: false)
    }
    
    @objc fileprivate func selectStreamingMode(_ sender: YJLActionMenuItem) {
        let rawValue = Int(sender.value)
        if let mode = LiveStreamMode(rawValue: rawValue) {
            connection.mode = mode
            modeButton.setTitle(mode.title, for: .normal)
        }
    }
    
    fileprivate func showTargetTypes(_ sender: UIView) {
        let menuItems = [
            YJLActionMenuItem("0.0s", image: nil, target: self, action: #selector(selectTargetType(_:)), value: 0.0),
        ]

        let frame = sender.convert(sender.bounds, to: self.view)
        YJLActionMenu.show(in: self.view, from: frame, menuItems: menuItems as [Any], isWhiteBG: false)
    }
    
    @objc fileprivate func selectTargetType(_ sender: YJLActionMenuItem) {
        
    }
    
    fileprivate func showAudioBitrates(_ sender: UIView) {
        var menuItems: [YJLActionMenuItem] = []
        let bitrates: [LiveStreamBitrate] = [.auto, .bps96, .bps128, .bps160, .bps256, .bps320]
        for bitrate in bitrates {
            menuItems.append(YJLActionMenuItem(bitrate.title, image: nil, target: self, action: #selector(selectAudioBitrate(_:)), value: CGFloat(bitrate.rawValue)))
        }
        
        let frame = sender.convert(sender.bounds, to: self.view)
        YJLActionMenu.show(in: self.view, from: frame, menuItems: menuItems as [Any], isWhiteBG: false)
    }
    
    fileprivate func showVideoBitrates(_ sender: UIView) {
        var menuItems: [YJLActionMenuItem] = []
        let bitrates: [LiveStreamBitrate] = [.auto, .bps320, .bps1200, .bps2500, .bps3500, .bps4500, .bps5500, .bps6500]
        for bitrate in bitrates {
            menuItems.append(YJLActionMenuItem(bitrate.title, image: nil, target: self, action: #selector(selectVideoBitrate(_:)), value: CGFloat(bitrate.rawValue)))
        }

        let frame = sender.convert(sender.bounds, to: self.view)
        YJLActionMenu.show(in: self.view, from: frame, menuItems: menuItems as [Any], isWhiteBG: false)
    }
    
    @objc fileprivate func selectAudioBitrate(_ sender: YJLActionMenuItem) {
        let rawValue = Int(sender.value)
        if let audioBitrate = LiveStreamBitrate(rawValue: rawValue) {
            connection.audioBitrate = audioBitrate
            audioBitrateButton.setTitle(audioBitrate.title, for: .normal)
        }
    }
    
    @objc fileprivate func selectVideoBitrate(_ sender: YJLActionMenuItem) {
        let rawValue = Int(sender.value)
        if let videoBitrate = LiveStreamBitrate(rawValue: rawValue) {
            connection.videoBitrate = videoBitrate
            videoBitrateButton.setTitle(videoBitrate.title, for: .normal)
        }
    }
    
    fileprivate func showFrameRates(_ sender: UIView) {
        var menuItems: [YJLActionMenuItem] = []
        let frameRates: [LiveStreamFrameRate] = [.fps10, .fps15, .fps20, .fps25, .fps30, .fps50, .fps60, .fps120]
        for frameRate in frameRates {
            menuItems.append(YJLActionMenuItem(frameRate.title, image: nil, target: self, action: #selector(selectFrameRate(_:)), value: CGFloat(frameRate.rawValue)))
        }

        let frame = sender.convert(sender.bounds, to: self.view)
        YJLActionMenu.show(in: self.view, from: frame, menuItems: menuItems as [Any], isWhiteBG: false)
    }
    
    @objc fileprivate func selectFrameRate(_ sender: YJLActionMenuItem) {
        let rawValue = Int(sender.value)
        if let frameRate = LiveStreamFrameRate(rawValue: rawValue) {
            connection.frameRate = frameRate
            frameRateButton.setTitle(frameRate.title, for: .normal)
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
    @IBAction func actionSave(_ sender: UIButton) {
        view.endEditing(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            if self.connection.name == "" {
                Utilities.showAlertView(error: nil, title: APP_NAME, message: "Please input a name.", from: self, nil)
                return
            }
            
            if self.connection.url.contains("rtmp://") == false, self.connection.url.contains("rtmps://") == false {
                Utilities.showAlertView(error: nil, title: APP_NAME, message: "Please enter a valid URL.", from: self, nil)
                return
            }
            
            if self.connection.key == "" {
                Utilities.showAlertView(error: nil, title: APP_NAME, message: "Please input a key.", from: self, nil)
                return
            }
            
            /*if UIApplication.shared.canOpenURL(URL(string: self.connection.url)!) == false {
                Utilities.showAlertView(error: nil, title: APP_NAME, message: "Please enter a valid URL.", from: self, nil)
                return
            }*/
            
            LiveStreamManager.shared.saveConnection(self.connection)
            LiveStreamManager.shared.refreshConnection()
            self.delegate?.didSaveConnection(self.connection)
            self.actionBack(sender)
        }
    }
    
    @IBAction func actionMode(_ sender: UIButton) {
        showModes(sender)
    }
    
    @IBAction func actionTargetType(_ sender: UIButton) {
        //showTargetTypes(sender)
    }
    
    @IBAction func actionAudioBitrate(_ sender: UIButton) {
        showAudioBitrates(sender)
    }
    
    @IBAction func actionVideoBitrate(_ sender: UIButton) {
        showVideoBitrates(sender)
    }
    
    @IBAction func actionFrameRate(_ sender: UIButton) {
        showFrameRates(sender)
    }
    
    @IBAction func textEditingChanged(_ sender: UITextField) {
        sender.text = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - UITextFieldDelegate
extension NewConnectionViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == modeTextField {
            showModes(modeButton)
            return false
        } else if textField == targetTypeTextField {
            //showTargetTypes(targetTypeButton)
            return false
        } else if textField == audioBitrateTextField {
            showAudioBitrates(audioBitrateButton)
            return false
        } else if textField == videoBitrateTextField {
            showVideoBitrates(videoBitrateButton)
            return false
        } else if textField == frameRateTextField {
            showFrameRates(frameRateButton)
            return false
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameTextField {
            self.connection.name = textField.text ?? ""
        } else if textField == urlTextField {
            self.connection.url = textField.text ?? ""
        } else if textField == keyTextField {
            self.connection.key = textField.text ?? ""
        } else if textField == loginTextField {
            self.connection.login = textField.text ?? ""
        } else if textField == passwordTextField {
            self.connection.password = textField.text ?? ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UITextViewDelegate
extension NewConnectionViewController: UITextViewDelegate {
    
}
