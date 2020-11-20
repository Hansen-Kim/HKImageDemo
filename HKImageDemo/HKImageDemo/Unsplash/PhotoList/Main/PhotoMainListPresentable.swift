//
//  PhotoMainListPresenter.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import Foundation

protocol PhotoMainListPresenterPrototype: PhotoListPresenterPrototype {
    
}

class PhotoMainListPresenter: PhotoMainListPresenterPrototype {
    private weak var view: PhotoListView!
    private var interactor: PhotoListInteractorPrototype
    private var router: PhotoListRouterPrototype
    
    init(with view: PhotoListView, interactor: PhotoListInteractorPrototype, router: PhotoListRouterPrototype) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    var hasMore: Bool {
        get { return self.interactor.hasMore }
    }
    
    func numberOfRow(in section: Int) -> Int {
        return section == 0 ? self.interactor.photos.count : 0
    }
    func didSelectedRow(at indexPath: IndexPath) {
        
    }
    func configure(photoContainerView: PhotoContainerView, at indexPath: IndexPath) {
        
    }
    
    func reload() {
        self.interactor.reload()
    }
    func more() {
        self.interactor.more()
    }
}
