//
//  BookmarkTableCell.swift
//  WebStreamer
//
//  Created by Yinjing Li on 8/16/23.
//

import UIKit

class BookmarkTableCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    var bookmark: Bookmark! {
        didSet {
            titleLabel.text = bookmark.url
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
