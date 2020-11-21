//
//  PhotoListInteractor.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import Foundation

protocol PhotoListInteractorOutput: class {
    func photosDidChanged()
    func currentPhotoDidChanged()
    func errorReceived(_ error: Error)
}

protocol PhotoListInteractorPrototype {
    var output: PhotoListInteractorOutput? { get set }
    
    var hasMore: Bool { get }
    var photos: [UnsplashPhoto] { get }
    
    var currentPhoto: UnsplashPhoto? { get set }
    
    func reload()
    func more()
}
