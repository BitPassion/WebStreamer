//
//  TabBarView.swift
//  WebStreamer
//
//  Created by Yinjing Li on 1/8/21.
//

import UIKit

enum WebBottomViewItem: Int {
    case back = 0
    case forward
    case share
    case home
    case tabs
}

protocol WebBottomViewDelegate {
    func didTapWebBottom(_ item: WebBottomViewItem)
}

class WebBottomView: UIView {

    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var tabsLabel: UILabel!
    
    public var delegate: WebBottomViewDelegate? = nil
    public var selectedIndex: Int = 0 {
        didSet {
            deselectButtons()
            if let button = tabBarView.viewWithTag(100 + selectedIndex) as? UIButton {
                button.isSelected = true
            }
            if let label = tabBarView.viewWithTag(200 + selectedIndex) as? UILabel {
                label.textColor = .label
            }
        }
    }
    
    public var canGoBack: Bool = false {
        didSet {
            if let button = tabBarView.viewWithTag(100) as? UIButton {
                button.isEnabled = canGoBack
            }
        }
    }
    
    public var canGoForward: Bool = false {
        didSet {
            if let button = tabBarView.viewWithTag(101) as? UIButton {
                button.isEnabled = canGoForward
            }
        }
    }
    
    var tabs: Int = 0 {
        didSet {
            if tabs >= 10 {
                tabsLabel.text = "9+"
            } else {
                tabsLabel.text = "\(tabs)"
            }
        }
    }
    
    static func loadFromNib() -> WebBottomView {
        return Bundle.main.loadNibNamed("WebBottomView", owner: self, options: nil)!.first as! WebBottomView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let imageSize: CGSize = Utilities.isPhone ? CGSize(width: 28.0, height: 28.0) : CGSize(width: 36.0, height: 36.0)
        var button = tabBarView.viewWithTag(100) as? UIButton
        button?.setImage(UIImage.svgImage(named: "arrow-left", color: .label, size: imageSize), for: .normal)
        button?.setImage(UIImage.svgImage(named: "arrow-left", color: .lightGray, size: imageSize), for: .disabled)
        button = tabBarView.viewWithTag(101) as? UIButton
        button?.setImage(UIImage.svgImage(named: "arrow-right", color: .label, size: imageSize), for: .normal)
        button?.setImage(UIImage.svgImage(named: "arrow-right", color: .lightGray, size: imageSize), for: .disabled)
        button = tabBarView.viewWithTag(102) as? UIButton
        //button?.setImage(UIImage.svgImage(named: "arrow-up-from-square", color: .label, size: CGSize(width: 24.0, height: 24.0)), for: .normal)
        //button?.setImage(UIImage.svgImage(named: "arrow-up-from-square", color: .lightGray, size: CGSize(width: 24.0, height: 24.0)), for: .disabled)
        button?.setImage(UIImage.svgImage(named: "gear", color: .label, size: imageSize), for: .normal)
        button?.setImage(UIImage.svgImage(named: "gear", color: .lightGray, size: imageSize), for: .disabled)
        button = tabBarView.viewWithTag(103) as? UIButton
        button?.setImage(UIImage.svgImage(named: "house", color: .label, size: imageSize), for: .normal)
        button?.setImage(UIImage.svgImage(named: "house", color: .lightGray, size: imageSize), for: .disabled)
        button = tabBarView.viewWithTag(104) as? UIButton
        button?.setImage(UIImage.svgImage(named: "rectangle", color: .label, size: imageSize), for: .normal)
        button?.setImage(UIImage.svgImage(named: "rectangle", color: .lightGray, size: imageSize), for: .disabled)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    fileprivate func deselectButtons() {
        for index in WebBottomViewItem.back.rawValue ... WebBottomViewItem.tabs.rawValue {
            if let button = tabBarView.viewWithTag(index + 100) as? UIButton {
                button.isSelected = false
            }
            if let label = tabBarView.viewWithTag(index + 200) as? UILabel {
                label.textColor = .lightGray
            }
        }
    }
    
    // MARK: - IBAction
    @IBAction func tabBarButtonPressed(_ sender: UIButton)  {
        delegate?.didTapWebBottom(WebBottomViewItem(rawValue: sender.tag - 100)!)
    }
}
