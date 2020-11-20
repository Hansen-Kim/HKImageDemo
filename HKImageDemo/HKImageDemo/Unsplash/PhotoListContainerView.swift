//
//  PhotoContainerView.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import UIKit

protocol PhotoContainerView: UIView {
    var photoImageView: UIImageView! { get }
    var photoTitleLabel: UILabel! { get }
}
