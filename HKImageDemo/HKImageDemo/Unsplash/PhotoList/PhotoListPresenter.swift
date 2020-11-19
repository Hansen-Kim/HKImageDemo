//
//  PhotoListPresenter.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import Foundation

protocol PhotoListPresenterPrototype: class, Presenter {
    var hasMore: Bool { get }
    
    func numberOfRow(in section: Int) -> Int
    func didSelectedRow(at indexPath: IndexPath)
    func configure(photoContainerView: PhotoContainerView, at indexPath: IndexPath)
    
    func reload()
    func more()
}
