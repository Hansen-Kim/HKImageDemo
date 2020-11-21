//
//  PhotoPageRouter.swift
//  HKImageDemo
//
//  Created by Seunghan Kim on 2020/11/22.
//

import Foundation

protocol PhotoPageRouterPrototype: Router {
    func close()
}

struct PhotoPageRouter: PhotoPageRouterPrototype {
    private(set) weak var photoPageView: PhotoPageView?
    init(with photoPageView: PhotoPageView) {
        self.photoPageView = photoPageView
    }
    
    var view: View? {
        return self.photoPageView
    }
    
    func close() {
        self.hide(animated: true)
    }
}
