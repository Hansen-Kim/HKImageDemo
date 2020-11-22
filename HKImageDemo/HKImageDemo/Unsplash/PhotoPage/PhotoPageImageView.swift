//
//  PhotoPageImageView.swift
//  HKImageDemo
//
//  Created by Seunghan Kim on 2020/11/20.
//

import UIKit

class PhotoPageImageView: UIView {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoTitleLabel: UILabel!
}

extension PhotoPageImageView: PhotoContainerView {
    func configure(with photo: UnsplashPhoto, parentView: UIView) {
        self.photoTitleLabel.attributedText = photo.title
        self.photoImageView.fetch(photo.image)

        self.configureZoomScale(with: photo, size: parentView.frame.size)
    }
    
    private func configureZoomScale(with photo: UnsplashPhoto, size: CGSize) {
        let photoSize = CGSize(width: photo.width, height: photo.height)
        let horizontalZoomScale = size.width / photoSize.width
        let verticalZoomScale = size.height / photoSize.height

        let zoomScale = min(horizontalZoomScale, verticalZoomScale)

        self.scrollView.minimumZoomScale = zoomScale
        self.scrollView.maximumZoomScale = max(zoomScale * 1.3, 1.0)
        self.scrollView.zoomScale = zoomScale
        
        switch (horizontalZoomScale, verticalZoomScale) {
        case (let horizontalZoomScale, let verticalZoomScale) where horizontalZoomScale > verticalZoomScale:
            let margin = (size.width - photoSize.width * zoomScale) / 2.0
            self.scrollView.contentInset = UIEdgeInsets(top: 0.0, left: margin, bottom: 0.0, right: margin)
            self.scrollView.contentOffset = CGPoint(x: -margin, y: 0.0)
            break
        case (let horizontalZoomScale, let verticalZoomScale) where horizontalZoomScale < verticalZoomScale:
            let margin = (size.height - photoSize.height * zoomScale) / 2.0
            self.scrollView.contentInset = UIEdgeInsets(top: margin, left: 0.0, bottom: margin, right: 0.0)
            self.scrollView.contentOffset = CGPoint(x: 0.0, y: -margin)
            break
        default:
            self.scrollView.contentInset = .zero
            self.scrollView.contentOffset = .zero
        }
    }
}

extension PhotoPageImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.photoImageView
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
                                    .font : UIFont.systemFont(ofSize: 16.0, weight: .bold)
                                   ])
            )
            user = sponsor
        } else {
            user = self.user
        }
        components.append(
            NSAttributedString(string: user.username,
                               attributes: [
                                .font : UIFont.systemFont(ofSize: 16.0, weight: .semibold)
                               ])
        )
        return components.joined(separator:
            NSAttributedString(string: "\n",
                               attributes: [
                                .font : UIFont.systemFont(ofSize: 16.0, weight: .semibold)
                               ]))
    }
    
    var image: Image {
        return .url(self.urls.full, placeholder: #imageLiteral(resourceName: "logo"))
    }
}
