//
//  PhotoMainListInteractor.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import Foundation

protocol PhotoMainListInteractorOutput: PhotoListInteractorOutput {
    #if RANDOM_PHOTO
    func randomPhotoDidChanged()
    #endif
}

protocol PhotoMainListInteractorProtoype: PhotoListInteractorPrototype {
    #if RANDOM_PHOTO
    var randomPhoto: UnsplashPhoto? { get }
    
    func fetchRandomPhoto()
    #endif
}

class PhotoMainListInteractor: PhotoMainListInteractorProtoype {
    weak var output: PhotoListInteractorOutput?
    var presenter: PhotoMainListInteractorOutput? {
        get { return self.output as? PhotoMainListInteractorOutput }
        set { self.output = newValue }
    }
    var hasMore: Bool {
        return self.photos.count > 0
    }
    
    private(set) var photos: [UnsplashPhoto] = [] {
        didSet {
            DispatchQueue.main.async {
                self.output?.photosDidChanged()
            }
        }
    }
    var currentPhoto: UnsplashPhoto? = nil {
        didSet {
            DispatchQueue.main.async {
                self.output?.currentPhotoDidChanged()
            }
        }
    }
    
    func reload() {
        self.photos.removeAll()
        
        self.fetchPhotos(page: 1)
    }
    
    func more() {
        self.fetchPhotos(page: self.currentPage + 1)
    }
    
    private var currentPage: Int = 1
    
    private func fetchPhotos(page: Int) {
        self.output?.willStartFetching()

        do {
            _ = try Unsplash
                .photoList(page: page)
                .session()
                .unsplashfetch { (result: APIResult<[UnsplashPhoto]>) in
                    switch result {
                        case .success(let value, _, _):
                            if page > 1 {
                                self.photos.append(contentsOf: value)
                            } else {
                                self.photos = value
                            }
                            self.currentPage = page
                        case .failure(let error, _, _):
                            self.errorReceived(error)
                    }
                    self.output?.didFinishFetched()
                }
        } catch let exception {
            self.output?.didFinishFetched()
            self.errorReceived(exception)
        }
    }
    
    #if RANDOM_PHOTO
    private(set) var randomPhoto: UnsplashPhoto? {
        didSet {
            DispatchQueue.main.async {
                self.presenter?.randomPhotoDidChanged()
            }
        }
    }

    func fetchRandomPhoto() {
        self.output?.willStartFetching()

        do {
            _ = try Unsplash
                .random
                .session()
                .unsplashfetch { (result: APIResult<UnsplashPhoto>) in
                    switch result {
                        case .success(let value, _, _):
                            self.randomPhoto = value
                        case .failure(let error, _, _):
                            self.errorReceived(error)
                    }
                    self.output?.didFinishFetched()
                }
        } catch let exception {
            self.output?.didFinishFetched()
            self.errorReceived(exception)
        }
    }
    #endif
    
    private func errorReceived(_ error: Error) {
        DispatchQueue.main.async {
            self.output?.errorReceived(error)
        }
    }
}
