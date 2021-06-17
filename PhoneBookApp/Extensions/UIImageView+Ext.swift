

import Foundation
import UIKit

extension UIImageView {
    
    //MARK: - To Make Rounded
    func makeRounded() {
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
