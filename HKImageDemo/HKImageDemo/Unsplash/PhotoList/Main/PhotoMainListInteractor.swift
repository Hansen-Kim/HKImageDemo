//
//  PhotoMainListInteractor.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import Foundation

protocol PhotoMainListInteractorOutput: PhotoListInteractorOutput {
    func randomPhotoDidChanged()
}

protocol PhotoMainListInteractorProtoype: PhotoListInteractorPrototype {
    var randomPhoto: UnsplashPhoto? { get }
    
    func fetchRandomPhoto()
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
    private(set) var randomPhoto: UnsplashPhoto? {
        didSet {
            DispatchQueue.main.async {
                self.presenter?.randomPhotoDidChanged()
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
                }
        } catch let exception {
            self.errorReceived(exception)
        }
    }
    
    func fetchRandomPhoto() {
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
                }
        } catch let exception {
            self.errorReceived(exception)
        }
    }
    
    private func errorReceived(_ error: Error) {
        DispatchQueue.main.async {
            self.output?.errorReceived(error)
        }
    }
}
