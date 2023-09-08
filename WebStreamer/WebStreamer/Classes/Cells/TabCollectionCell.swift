//
//  TabCollectionCell.swift
//  WebStreamer
//
//  Created by Yinjing Li on 8/1/23.
//

import UIKit

protocol TabCollectionCellDelegate {
    func didTapRemove(_ cell: TabCollectionCell)
}

class TabCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var removeButton: UIButton!
    
    var url: LiveURL! {
        didSet {
            thumbImageView.image = UIImage(contentsOfFile: url.thumbURL.path)
        }
    }
    
    var isSelection: Bool = false {
        didSet {
            if isSelection {
                borderView.borderColor = .systemBlue
            } else {
                borderView.borderColor = .systemGray4
            }
        }
    }
    
    var delegate: TabCollectionCellDelegate? = nil
    var index: Int = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        thumbImageView.contentMode = .scaleAspectFill
    }
    
    // MARK: - IBAction
    @IBAction func didTapRemove(_ sender: UIButton) {
        delegate?.didTapRemove(self)
    }
}
