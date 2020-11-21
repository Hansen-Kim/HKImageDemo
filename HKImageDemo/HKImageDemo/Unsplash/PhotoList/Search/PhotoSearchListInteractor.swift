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
    var query: String { get set }
}

class PhotoSearchListInteractor: PhotoSearchListInteractorPrototype {
    weak var output: PhotoListInteractorOutput?
    var presenter: PhotoSearchListInteractorOutput? {
        get { return self.output as? PhotoSearchListInteractorOutput }
        set { self.output = newValue }
    }

    private(set) var hasMore: Bool = false
    
    var query: String = "" {
        didSet {
            self.reload()
        }
    }
    
    var photos: [UnsplashPhoto] = [] {
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
        self.currentPage = 1
        self.hasMore = false
        
        self.fetchPhotos(query: self.query, page: 1)
    }
    
    func more() {
        self.fetchPhotos(query: self.query, page: self.currentPage + 1)
    }
    
    private var currentPage: Int = 1
    
    private func fetchPhotos(query: String, page: Int) {
        guard query.count > 2 else { return }
        
        do {
            _ = try Unsplash
                .searchPhoto(query: query, page: page)
                .session()
                .unsplashfetch { (result: APIResult<UnsplashPhotoContainer>) in
                    switch result {
                        case .success(let value, _, _):
                            self.hasMore = value.totalPages > page
                            if page > 1 {
                                self.photos.append(contentsOf: value.results)
                            } else {
                                self.photos = value.results
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
            self.output?.errorReceived(error)
        }
    }
}
