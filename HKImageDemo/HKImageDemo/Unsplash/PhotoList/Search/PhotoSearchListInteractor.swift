//
//  PhotoSearchListInteractor.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/20.
//

import Foundation

protocol PhotoSearchListInteractorOutput: PhotoListInteractorOutput {

}

protocol PhotoSearchListInteractorPrototype: PhotoListInteractorPrototype {
    
}

class PhotoSearchListInteractor: PhotoSearchListInteractorPrototype {
    weak var presenter: PhotoSearchListInteractorOutput?
    
    var hasMore: Bool {
        return false
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
    }
    
    func more() {

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
