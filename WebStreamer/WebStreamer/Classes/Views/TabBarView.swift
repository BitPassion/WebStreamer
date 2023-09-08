//
//  TabBarView.swift
//  WebStreamer
//
//  Created by Yinjing Li on 1/8/21.
//

import UIKit

enum TabBarIndex: Int {
    case home = 0
    case tabs
    case streamer
}

protocol TabBarViewDelegate {
    func didSelectTabBar(_ index: TabBarIndex)
}

class TabBarView: UIView {

    @IBOutlet weak var tabBarView: UIView!
    @IBOutlet weak var tabsLabel: UILabel!
    
    @IBOutlet var horizontalLabelConstraints: [NSLayoutConstraint] = []
    @IBOutlet var verticalLabelConstraints: [NSLayoutConstraint] = []
    @IBOutlet var horizontalTabsConstraint: NSLayoutConstraint!
    @IBOutlet var verticalTabsConstraint: NSLayoutConstraint!
    
    public var delegate: TabBarViewDelegate? = nil
    public var selectedIndex: Int = 0 {
        didSet {
            deselectButtons()
            if let button = tabBarView.viewWithTag(100 + selectedIndex) as? UIButton {
                button.isSelected = true
            }
            if let label = tabBarView.viewWithTag(200 + selectedIndex) as? UILabel {
                label.textColor = .systemBlue
            }
            if selectedIndex == TabBarIndex.tabs.rawValue {
                tabsLabel.textColor = .systemBlue
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
    
    var orientation: UIInterfaceOrientation = .portrait {
        didSet {
            if orientation == .portrait || orientation == .portraitUpsideDown {
                for constraint in horizontalLabelConstraints {
                    constraint.constant = 0.0
                }
                for constraint in verticalLabelConstraints {
                    if Utilities.isPhone {
                        constraint.constant = 14.0
                    } else {
                        constraint.constant = 20.0
                    }
                }
                for view in tabBarView.subviews {
                    if let button = view as? UIButton {
                        if Utilities.isPhone {
                            button.imageEdgeInsets = UIEdgeInsets(top: -12.0, left: 0, bottom: 0, right: 0)
                        } else {
                            button.imageEdgeInsets = UIEdgeInsets(top: -18.0, left: 0, bottom: 0, right: 0)
                        }
                    }
                }
                horizontalTabsConstraint.constant = 0.0
                if Utilities.isPhone {
                    verticalTabsConstraint.constant = -5.0
                } else {
                    verticalTabsConstraint.constant = -8.0
                }
            } else {
                for constraint in horizontalLabelConstraints {
                    if Utilities.isPhone {
                        constraint.constant = 28.0
                    } else {
                        constraint.constant = 36.0
                    }
                }
                for constraint in verticalLabelConstraints {
                    constraint.constant = 2.0
                }
                for view in tabBarView.subviews {
                    if let button = view as? UIButton {
                        if Utilities.isPhone {
                            button.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -24.0, bottom: 0, right: 0)
                        } else {
                            button.imageEdgeInsets = UIEdgeInsets(top: 0.0, left: -30.0, bottom: 0, right: 0)
                        }
                    }
                }
                if Utilities.isPhone {
                    horizontalTabsConstraint.constant = -12.0
                } else {
                    horizontalTabsConstraint.constant = -15.0
                }
                verticalTabsConstraint.constant = 1.0
            }
        }
    }
    
    static func loadFromNib() -> TabBarView {
        return Bundle.main.loadNibNamed("TabBarView", owner: self, options: nil)!.first as! TabBarView
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let imageSize: CGSize = Utilities.isPhone ? CGSize(width: 28.0, height: 28.0) : CGSize(width: 36.0, height: 36.0)
        var button = tabBarView.viewWithTag(100) as? UIButton
        button?.setImage(UIImage.svgImage(named: "house", color: .systemBlue, size: imageSize), for: .selected)
        button?.setImage(UIImage.svgImage(named: "house", color: .label, size: imageSize), for: .normal)
        button = tabBarView.viewWithTag(101) as? UIButton
        button?.setImage(UIImage.svgImage(named: "rectangle", color: .systemBlue, size: imageSize), for: .selected)
        button?.setImage(UIImage.svgImage(named: "rectangle", color: .label, size: imageSize), for: .normal)
        button = tabBarView.viewWithTag(102) as? UIButton
        button?.setImage(UIImage.svgImage(named: "signal-stream", color: .systemBlue, size: imageSize), for: .selected)
        button?.setImage(UIImage.svgImage(named: "signal-stream", color: .label, size: imageSize), for: .normal)
        
        if Utilities.isPhone == false {
            for index in TabBarIndex.home.rawValue ... TabBarIndex.streamer.rawValue {
                if let label = tabBarView.viewWithTag(index + 200) as? UILabel {
                    label.font = .custom(size: 14.0, weight: .semiBold)
                }
            }
            tabsLabel.font = .custom(size: 14.0, weight: .semiBold)
            
            for view in tabBarView.subviews {
                if let button = view as? UIButton {
                    button.imageEdgeInsets = UIEdgeInsets(top: -18.0, left: 0, bottom: 0, right: 0)
                }
            }
            
            for constraint in verticalLabelConstraints {
                constraint.constant = 20.0
            }
            
            verticalTabsConstraint.constant = -8.0
        }
        
        self.orientation = UIApplication.orientation()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    fileprivate func deselectButtons() {
        for index in TabBarIndex.home.rawValue ... TabBarIndex.streamer.rawValue {
            if let button = tabBarView.viewWithTag(index + 100) as? UIButton {
                button.isSelected = false
            }
            if let label = tabBarView.viewWithTag(index + 200) as? UILabel {
                label.textColor = .label
            }
        }
        tabsLabel.textColor = .label
    }
    
    // MARK: - IBAction
    @IBAction func tabBarButtonPressed(_ sender: UIButton)  {
        delegate?.didSelectTabBar(TabBarIndex(rawValue: sender.tag - 100)!)
    }
}
