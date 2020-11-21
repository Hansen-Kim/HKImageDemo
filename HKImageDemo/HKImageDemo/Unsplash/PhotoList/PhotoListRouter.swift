//
//  PhotoListRouter.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import UIKit

protocol PhotoListRouterPrototype: Router {
    func showPhotoPage(with interactor: PhotoListInteractorPrototype)
}

class PhotoListRouter: PhotoListRouterPrototype {
    private(set) weak var photoListView: PhotoListView?
    init(with view: PhotoListView) {
        self.photoListView = view
    }
    
    var view: View? {
        get { return self.photoListView }
    }
    
    func showPhotoPage(with interactor: PhotoListInteractorPrototype) {
        self.show(with: SegueIdentifier<PhotoPageViewController>()) { (_, destination) in
            if let photoPageViewController = destination as? PhotoPageViewController {
                let interactor = PhotoPageInteractor(with: interactor)
                let router = PhotoPageRouter(with: photoPageViewController)
                let presenter = PhotoPagePresenter(with: photoPageViewController, interactor: interactor, router: router)

                interactor.presenter = presenter
                photoPageViewController.presenter = presenter
            }
        }
    }
}
