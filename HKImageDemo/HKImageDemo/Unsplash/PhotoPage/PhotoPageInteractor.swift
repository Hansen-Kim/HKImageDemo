//
//  PhotoPageInteractor.swift
//  HKImageDemo
//
//  Created by Seunghan Kim on 2020/11/22.
//

import Foundation

protocol PhotoPageInteractorOutput: PhotoListInteractorOutput {
    
}

protocol PhotoPageInteractorPrototype: PhotoListInteractorPrototype {
    func index(of photo: UnsplashPhoto?) -> Int?
}

class PhotoPageInteractor: PhotoPageInteractorPrototype {
    weak var presenter: PhotoPageInteractorOutput?
    var output: PhotoListInteractorOutput? {
        get { return self.presenter }
        set { self.presenter = newValue as? PhotoPageInteractorOutput }
    }

    private var baseInteractor: PhotoListInteractorPrototype
    private weak var previousOutput: PhotoListInteractorOutput?
    
    init(with interactor: PhotoListInteractorPrototype) {
        self.baseInteractor = interactor
        self.previousOutput = interactor.output
        
        self.baseInteractor.output = self
    }
    
    deinit {
        self.baseInteractor.currentPhoto = nil
        self.baseInteractor.output = self.previousOutput
    }
    
    var hasMore: Bool {
        return self.baseInteractor.hasMore
    }
    
    var photos: [UnsplashPhoto] {
        return self.baseInteractor.photos
    }
    var currentPhoto: UnsplashPhoto? {
        get { return self.baseInteractor.currentPhoto }
        set { self.baseInteractor.currentPhoto = newValue }
    }
    
    func index(of photo: UnsplashPhoto?) -> Int? {
        guard let photo = photo else { return nil }
        return self.photos.firstIndex(of: photo)
    }

    func reload() {
        self.baseInteractor.reload()
    }
    
    func more() {
        self.baseInteractor.more()
    }
}

extension PhotoPageInteractor: PhotoListInteractorOutput {
    func willStartFetching() {
        self.output?.willStartFetching()
    }
    
    func didFinishFetched() {
        self.output?.didFinishFetched()
    }
    
    func photosDidChanged() {
        self.presenter?.photosDidChanged()
        self.previousOutput?.photosDidChanged()
    }
    
    func currentPhotoDidChanged() {
        self.presenter?.currentPhotoDidChanged()
        self.previousOutput?.currentPhotoDidChanged()
    }
    
    func errorReceived(_ error: Error) {
        
    }
}
