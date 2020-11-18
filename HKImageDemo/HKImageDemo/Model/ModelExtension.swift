//
//  ModelExtension.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/18.
//

import UIKit

extension UnsplashPhoto.Color {
    var asColor: UIColor {
        return UIColor(hexString: self.string)
    }
}
