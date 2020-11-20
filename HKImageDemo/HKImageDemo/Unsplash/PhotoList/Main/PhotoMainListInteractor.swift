//
//  PhotoMainListInteractor.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import Foundation

protocol PhotoMainListInteractorProtoype: PhotoListInteractorPrototype {
    
}

class PhotoMainListInteractor: PhotoMainListInteractorProtoype {
    weak var presenter: PhotoListInteractorOutput?
    
    var hasMore: Bool {
        return self.photos.count > 0
    }
    
    var photos: [UnsplashPhoto] = [] {
        didSet {
            DispatchQueue.main.async {
                self.presenter?.photosDidChanged()
            }
        }
    }
    var currentPhoto: UnsplashPhoto? = nil {
        didSet {
            DispatchQueue.main.async {
                self.presenter?.currentPhotoDidChanged()
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
                .photoList(page: self.currentPage)
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
    
    private func errorReceived(_ error: Error) {
        DispatchQueue.main.async {
            self.presenter?.errorReceived(error)
        }
    }
}
