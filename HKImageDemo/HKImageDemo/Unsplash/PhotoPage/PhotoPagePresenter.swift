//
//  PhotoPagePresenter.swift
//  HKImageDemo
//
//  Created by Seunghan Kim on 2020/11/22.
//

import UIKit

protocol PhotoPagePresenterPrototype: class, Presenter {
    var hasMore: Bool { get }
    var currentPageIndex: Int { get set }

    var numberOfContentView: Int  { get }
    func configure(parentView: UIView, photoContainerView: PhotoContainerView, at index: Int)

    func close()
    func more()
}

class PhotoPagePresenter: PhotoPagePresenterPrototype {
    private(set) weak var view: PhotoPageView!
    private(set) var interactor: PhotoPageInteractorPrototype
    private(set) var router: PhotoPageRouterPrototype

    init(with view: PhotoPageView, interactor: PhotoPageInteractorPrototype, router: PhotoPageRouterPrototype) {
        self.view = view
        self.interactor = interactor
        self.router = router
        
        self.currentPageIndex = interactor.index(of: interactor.currentPhoto) ?? 0
    }
    
    func viewDidLayoutSubviews() {
        self.view.scroll(to: self.currentPageIndex)
        self.view.reloadData()
    }
    
    fileprivate var fetchCount: Int = 0

    var hasMore: Bool {
        return self.interactor.hasMore
    }

    var numberOfContentView: Int {
        return self.interactor.photos.count
    }
    
    var currentPageIndex: Int {
        didSet {
            if self.currentPageIndex != self.interactor.index(of: self.interactor.currentPhoto) {
                self.interactor.currentPhoto = self.photo(at: self.currentPageIndex)
            }
        }
    }
    
    func configure(parentView: UIView, photoContainerView: PhotoContainerView, at index: Int) {
        let photo = self.photo(at: index)
        
        photoContainerView.configure(with: photo, parentView: parentView)
    }

    func close() {
        self.router.close()
    }
    
    func more() {
        self.interactor.more()
    }
    
    private func photo(at index: Int) -> UnsplashPhoto {
        return self.interactor.photos[index]
    }
}

extension PhotoPagePresenter: PhotoPageInteractorOutput {
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
        
    }
    
    func errorReceived(_ error: Error) {
        self.view.show(errorMessage: error.localizedDescription)
    }
}
