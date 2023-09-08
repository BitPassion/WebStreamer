//
//  ConnectionViewCell.swift
//  MyOSRadio
//
//  Created by Yinjing Li on 5/22/23.
//

import UIKit

class ConnectionViewCell: SwipeTableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var selectionSwitch: UISwitch!
    @IBOutlet weak var selectionImageView: UIImageView!
    
    var connection: LiveStream! {
        didSet {
            nameLabel.text = connection.name
            urlLabel.text = connection.url
        }
    }
    
    var isSelection: Bool = false {
        didSet {
            //selectionImageView.isHidden = !isSelection
            selectionSwitch.isOn = isSelection
        }
    }
    
    var didChangeSelection: ((Bool) -> Void)? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        selectionImageView.isHidden = true
        selectionImageView.alpha = 0.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func selectionChanged(_ sender: UISwitch) {
        didChangeSelection?(sender.isOn)
    }
}
