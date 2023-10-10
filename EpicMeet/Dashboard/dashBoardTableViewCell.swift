//
//  dashBoardTableViewCell.swift
//  EpicMeet
//
//  Created by R Unnikrishnan on 26/09/23.
//

import UIKit

class dashBoardTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var callBtn : UIButton!
    @IBOutlet weak var noOfParticipants: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
