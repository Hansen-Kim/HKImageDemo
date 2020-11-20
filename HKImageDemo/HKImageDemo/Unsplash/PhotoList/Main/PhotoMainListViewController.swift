//
//  PhotoMainListViewController.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import UIKit

protocol PhotoMainListView: PhotoListView {
    func changeNavigationImage()
}

class PhotoMainListViewController: PhotoListViewController {
    private var mainPresenter: PhotoMainListPresenter? {
        return self.presenter as? PhotoMainListPresenter
    }
    
    fileprivate var image: Image? = nil
    fileprivate var imageSession: APISession? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        self.mainPresenter?.viewWillAppear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.mainPresenter?.viewWillDisappear()
    }
}

extension PhotoMainListViewController: PhotoMainListView {
    func changeNavigationImage() {
        if #available(iOS 13.0, *) {
            self.imageSession = nil
            if let randomPhoto = self.mainPresenter?.randomPhoto {
                let image = Image.url(randomPhoto.urls.regular, placeholder: nil)
                self.image = image
                
                image.fetch { [weak self] (session, result) in
                    guard let self = self else { return }
                    switch (session, result) {
                        case (nil, let result):
                            self.image = nil
                            self.setNavigationBarBackgroundImage(result)
                        case (let session, nil):
                            if self.image == image {
                                self.imageSession = session
                            }
                        case (let session, let result):
                            if self.image == image, session === self.imageSession {
                                self.image = nil
                                self.setNavigationBarBackgroundImage(result)
                            }
                    }
                }
            }
        }
    }
    
    func setNavigationBarBackgroundImage(_ image: UIImage?) {
        if #available(iOS 13.0, *) {
            if let image = image {
                let appearance = UINavigationBarAppearance()
                appearance.configureWithTransparentBackground()
                appearance.backgroundImage = image
                
                self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
                self.navigationController?.navigationBar.setNeedsLayout()
                self.navigationController?.navigationBar.layoutIfNeeded()
            } else {
                self.navigationController?.navigationBar.scrollEdgeAppearance = nil
            }
        }
    }
}
