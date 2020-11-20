//
//  PhotoListTableViewCell.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/20.
//

import UIKit

class PhotoListTableViewCell: UITableViewCell {
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var photoTitleLabel: UILabel!
    @IBOutlet var heightConstraint: NSLayoutConstraint!
}

extension PhotoListTableViewCell: PhotoContainerView { }
