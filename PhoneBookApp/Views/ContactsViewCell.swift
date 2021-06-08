

import UIKit

class ContactsViewCell: UITableViewCell {

    
    @IBOutlet weak var contactImage: UIImageView!{
        didSet{
            contactImage.makeRounded()
        }
    }
    @IBOutlet weak var contactFullNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
