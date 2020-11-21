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
}

extension PhotoListTableViewCell: PhotoContainerView {
    func configure(with photo: UnsplashPhoto, parentView: UIView) {
        self.photoTitleLabel.attributedText = photo.title
        self.photoImageView.fetch(photo.image)
    }
}

private extension UnsplashPhoto {
    var title: NSAttributedString {
        var components: [NSAttributedString] = []
        let user: UnsplashUser
        if let sponsor = self.sponsorship?.sponsor {
            components.append(
                NSAttributedString(string: "Sponsor",
                                   attributes: [
                                    .font : UIFont.systemFont(ofSize: 14.0, weight: .bold)
                                   ])
            )
            user = sponsor
        } else {
            user = self.user
        }
        components.append(
            NSAttributedString(string: user.username,
                               attributes: [
                                .font : UIFont.systemFont(ofSize: 14.0, weight: .semibold)
                               ])
        )
        return components.joined(separator:
            NSAttributedString(string: "\n",
                               attributes: [
                                .font : UIFont.systemFont(ofSize: 14.0, weight: .semibold)
                               ]))
    }
    
    var image: Image {
        return .url(self.urls.regular, placeholder: #imageLiteral(resourceName: "placeholder.png"))
    }
}
