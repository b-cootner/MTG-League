//
//  Constants.swift
//  Whispering-Plateau
//
//  Created by Ben Cootner on 7/2/19.
//  Copyright © 2019 Ben Cootner. All rights reserved.
//

import Foundation
import UIKit

class Constants {
    static let backgroundColor = UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 235.0/255.0, alpha: 1.0)

    static var circleIcon: UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "circle")
        } else {
            return UIImage(named: "circle")
        }
    }

    static var circleFilledIcon: UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "circle.fill")
        } else {
            return UIImage(named: "circle.fill")
        }
    }
}
