//
//  CommonExtension.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/18.
//

import UIKit

extension CustomStringConvertible where Self: RawRepresentable, Self.RawValue: CustomStringConvertible {
    var description: String { return self.rawValue.description }
}

extension Hashable where Self: CustomStringConvertible {
    func hash(into hasher: inout Hasher) {
        self.description.hash(into: &hasher)
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hexString = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var hex: UInt64 = 0
        
        Scanner(string: hexString).scanHexInt64(&hex)
        
        let alpha: CGFloat
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        
        switch hexString.count {
        case 3:
            alpha = 255.0
            red = CGFloat(hex >> 8 & 0xF) * 17.0
            green = CGFloat(hex >> 4 & 0xF) * 17.0
            blue = CGFloat(hex & 0xF) * 17.0
        case 6:
            alpha = 255.0
            red = CGFloat(hex >> 16 & 0xFF)
            green = CGFloat(hex >> 8 & 0xFF)
            blue = CGFloat(hex & 0xFF)
        case 8:
            alpha = CGFloat(hex >> 24 & 0xFF)
            red = CGFloat(hex >> 16 & 0xFF)
            green = CGFloat(hex >> 8 & 0xFF)
            blue = CGFloat(hex & 0xFF)
        default:
            alpha = 255.0
            red = 0.0
            green = 0.0
            blue = 0.0
        }
        
        self.init(red: red / 255.0,
                  green: green / 255.0,
                  blue: blue / 255.0,
                  alpha: alpha / 255.0)
    }
}
