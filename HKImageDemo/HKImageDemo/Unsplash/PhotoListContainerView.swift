//
//  PhotoContainerView.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import UIKit

protocol PhotoContainerView {
    var photoImageView: UIImageView! { get }
    var photoTitleLabel: UILabel! { get }
}

class PhotoListTableViewCell: UITableViewCell {
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var photoTitleLabel: UILabel!
}

extension PhotoListTableViewCell: PhotoContainerView { }
