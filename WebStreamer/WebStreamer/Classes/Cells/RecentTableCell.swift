//
//  RecentTableCell.swift
//  WebStreamer
//
//  Created by Yinjing Li on 8/1/23.
//

import UIKit

class RecentTableCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var url: LiveURL! {
        didSet {
            titleLabel.text = url.url
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        iconImageView.image = UIImage.svgImage(named: "earth-americas", color: .black, size: CGSize(width: 20.0, height: 20.0))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
