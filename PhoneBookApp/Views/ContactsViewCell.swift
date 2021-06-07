//
//  ContactsViewCell.swift
//  PhoneBookApp
//
//  Created by Tolga on 6.06.2021.
//

import UIKit

class ContactsViewCell: UITableViewCell {

    
    @IBOutlet weak var contactImage: UIImageView!{
        didSet{
            contactImage.makeRounded()
        }
    }
    @IBOutlet weak var contactNameLabel: UILabel!
    
    
    @IBOutlet weak var contactSirnameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
