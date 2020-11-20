//
//  PhotoMainListPresenter.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import Foundation

protocol PhotoMainListPresenterPrototype: PhotoListPresenterPrototype {
    var randomPhoto: UnsplashPhoto? { get }
}

class PhotoMainListPresenter: PhotoListPresenter, PhotoMainListPresenterPrototype, PhotoMainListInteractorOutput {
    private var mainInteractor: PhotoMainListInteractor? {
        return self.interactor as? PhotoMainListInteractor
    }
    private var mainRouter: PhotoMainListRouter? {
        return self.router as? PhotoMainListRouter
    }
    var randomPhoto: UnsplashPhoto? { self.mainInteractor?.randomPhoto }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mainRouter?.configureSearchView()
    }
    
    func viewWillAppear() {
        if #available(iOS 13.0, *) {
            self.mainInteractor?.fetchRandomPhoto()
        }
    }
    func viewWillDisappear() {
        
    }

    func randomPhotoDidChanged() {
        (self.view as? PhotoMainListView)?.changeNavigationImage()
    }
}
