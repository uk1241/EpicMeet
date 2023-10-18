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
    @IBOutlet weak var BgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        let borderClr = 0x009DFF
        profileImage.layer.cornerRadius = profileImage.frame.size.width / 2
        profileImage.clipsToBounds = true
        callBtn.layer.borderWidth = 1
        callBtn.layer.borderColor = UIColor.init(hex: borderClr).cgColor
        callBtn.layer.cornerRadius = 16
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    override func layoutSubviews()
       {
           super.layoutSubviews()

           contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10))
       }
    
}


extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
