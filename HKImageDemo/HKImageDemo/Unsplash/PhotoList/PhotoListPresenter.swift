//
//  PhotoListPresenter.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import Foundation

protocol PhotoListPresenterPrototype: class, Presenter {
    var hasMore: Bool { get }
    
    func numberOfRow(in section: Int) -> Int
    func didSelectedRow(at indexPath: IndexPath)
    func configure(photoContainerView: PhotoContainerView, at indexPath: IndexPath)
    
    func reload()
    func more()
}

class PhotoListPresenter: PhotoListPresenterPrototype {
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
        self.interactor.currentPhoto = self.photo(at: indexPath)
        self.router.showPhotoPage(with: self.interactor)
    }
    func configure(photoContainerView: PhotoContainerView, at indexPath: IndexPath) {
        
    }
    
    func reload() {
        self.interactor.reload()
    }
    func more() {
        self.interactor.more()
    }
    
    private func photo(at indexPath: IndexPath) -> UnsplashPhoto {
        return self.interactor.photos[indexPath.row]
    }
}

extension PhotoListPresenter: PhotoListInteractorOutput {
    func photosDidChanged() {
        self.view.reloadData()
    }

    func currentPhotoDidChanged() {
        if let currentPhoto = self.interactor.currentPhoto, let index = self.interactor.photos.firstIndex(of: currentPhoto) {
            self.view.scroll(to: IndexPath(row: index, section: 0))
        }
    }
    
    func errorReceived(_ error: Error) {
        self.view.show(errorMessage: error.localizedDescription)
    }
}
