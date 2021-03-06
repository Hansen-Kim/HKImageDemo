//
//  PhotoListPresenter.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import UIKit

protocol PhotoListPresenterPrototype: class, Presenter {
    var hasMore: Bool { get }
    
    func numberOfRow(in section: Int) -> Int
    func didSelectedRow(at indexPath: IndexPath)
    func heightForRow(parentView: UIView, at indexPath: IndexPath) -> CGFloat
    func configure(parentView: UIView, photoContainerView: PhotoContainerView, at indexPath: IndexPath)
    
    func reload()
    func more()
}

class PhotoListPresenter: PhotoListPresenterPrototype {
    private(set) weak var view: PhotoListView!
    private(set) var interactor: PhotoListInteractorPrototype
    private(set) var router: PhotoListRouterPrototype
    
    init(with view: PhotoListView, interactor: PhotoListInteractorPrototype, router: PhotoListRouterPrototype) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    fileprivate var fetchCount: Int = 0

    var hasMore: Bool {
        return self.interactor.hasMore
    }

    func numberOfRow(in section: Int) -> Int {
        return section == 0 ? self.interactor.photos.count : 0
    }
    func didSelectedRow(at indexPath: IndexPath) {
        self.interactor.currentPhoto = self.photo(at: indexPath)
        self.router.showPhotoPage(with: self.interactor)
    }
    func heightForRow(parentView: UIView, at indexPath: IndexPath) -> CGFloat {
        let photo = self.photo(at: indexPath)
        
        let width = parentView.bounds.size.width
        return ceil((CGFloat(photo.height) * width) / CGFloat(photo.width))
    }
    func configure(parentView: UIView, photoContainerView: PhotoContainerView, at indexPath: IndexPath) {
        let photo = self.photo(at: indexPath)

        photoContainerView.configure(with: photo, parentView: parentView)
    }
    
    func viewDidLoad() {
        self.reload()
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
    func willStartFetching() {
        DispatchQueue.main.async {
            if self.fetchCount == 0 {
                self.view.willStartFetching()
            }
            self.fetchCount += 1
        }
    }
    func didFinishFetched() {
        DispatchQueue.main.async {
            self.fetchCount -= 1
            if self.fetchCount == 0 {
                self.view.didFinishFetched()
            }
        }
    }

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
