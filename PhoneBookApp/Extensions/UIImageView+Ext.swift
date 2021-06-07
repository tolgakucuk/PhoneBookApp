//
//  UIImageView+Ext.swift
//  PhoneBookApp
//
//  Created by Tolga on 6.06.2021.
//

import Foundation
import UIKit

extension UIImageView {

    func makeRounded() {
        self.layer.borderWidth = 1.0
        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}
