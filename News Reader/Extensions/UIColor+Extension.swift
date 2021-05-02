//
//  UIColor+Extension.swift
//  News Reader
//
//  Created by M Habib Ali Akbar on 27/04/21.
//

import Foundation
import UIKit

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: 1)
    }
    
    static let newsBlue = UIColor.rgb(red: 83, green: 124, blue: 172)
}
