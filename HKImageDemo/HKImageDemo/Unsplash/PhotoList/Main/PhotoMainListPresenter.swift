//
//  PhotoMainListPresenter.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import Foundation

protocol PhotoMainListPresenterPrototype: PhotoListPresenterPrototype {
    #if RANDOM_PHOTO
    var randomPhoto: UnsplashPhoto? { get }
    #endif
}

class PhotoMainListPresenter: PhotoListPresenter, PhotoMainListPresenterPrototype, PhotoMainListInteractorOutput {
    private var mainInteractor: PhotoMainListInteractor? {
        return self.interactor as? PhotoMainListInteractor
    }
    private var mainRouter: PhotoMainListRouter? {
        return self.router as? PhotoMainListRouter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainRouter?.configureSearchView()
    }
    
    #if RANDOM_PHOTO
    var randomPhoto: UnsplashPhoto? { self.mainInteractor?.randomPhoto }

    func viewWillAppear() {
        if #available(iOS 13.0, *) {
            self.mainInteractor?.fetchRandomPhoto()
        }
    }

    func randomPhotoDidChanged() {
        (self.view as? PhotoMainListView)?.changeNavigationImage()
    }
    #endif
}
