//
//  PhotoSearchListPresenter.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/20.
//

import Foundation

protocol PhotoSearchListPresenterPrototype: PhotoListPresenterPrototype {

}

class PhotoSearchListPresenter: PhotoListPresenter, PhotoSearchListPresenterPrototype, PhotoSearchListInteractorOutput {
    private var searchInteractor: PhotoSearchListInteractor? {
        return self.interactor as? PhotoSearchListInteractor
    }
}
