//
//  UITextField+Ext.swift
//  PhoneBookApp
//
//  Created by Tolga on 5.06.2021.
//

import Foundation
import UIKit

extension UITextField {
  func setLeftView(image: UIImage) {
    let iconView = UIImageView(frame: CGRect(x: 15, y: 10, width: 25, height: 25)) 
    iconView.image = image
    let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 45))
    iconContainerView.addSubview(iconView)
    leftView = iconContainerView
    leftViewMode = .always
    self.tintColor = .lightGray
  }
}
