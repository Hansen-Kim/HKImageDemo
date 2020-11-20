//
//  PhotoListRouter.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import Foundation

protocol PhotoListRouterPrototype: Router {
    func showPhotoPage(with interactor: PhotoListInteractorPrototype)
}

struct PhotoListRouter: PhotoListRouterPrototype {
    private weak var photoListView: PhotoListView?
    init(with view: PhotoListView) {
        self.photoListView = view
    }
    
    var view: View? {
        get { return self.photoListView }
    }
    
    func showPhotoPage(with interactor: PhotoListInteractorPrototype) {
        
    }
}
