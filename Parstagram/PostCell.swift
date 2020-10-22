//
//  PostCell.swift
//  Parstagram
//
//  Created by Zainab Alibhai on 10/22/20.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var postView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
