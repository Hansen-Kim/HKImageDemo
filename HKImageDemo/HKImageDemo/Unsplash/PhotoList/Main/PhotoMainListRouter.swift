//
//  PhotoMainListRouter.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/20.
//

import UIKit

protocol PhotoMainListRouterPrototype: Router {
    func configureSearchView()
}

class PhotoMainListRouter: PhotoListRouter, PhotoMainListRouterPrototype {
    private var mainPhotoListView: PhotoMainListView? {
        return self.photoListView as? PhotoMainListView
    }

    func configureSearchView() {
        let transition: (View, View) -> Void = { (source, destination) in
            if let mainPhotoListViewController = source as? PhotoMainListViewController,
               let searchPhotoListViewController = destination as? PhotoSearchListViewController {
                let searchController = UISearchController(searchResultsController: searchPhotoListViewController)
                searchController.searchResultsUpdater = searchPhotoListViewController
                mainPhotoListViewController.navigationItem.searchController = searchController
            }
        }
        
        self.show(with: SegueIdentifier<PhotoSearchListViewController>(),
                  routeType: .custom(transition: transition), animated: false) { (_, destination) in
            if let searchListViewController = destination as? PhotoSearchListViewController {
                let interactor = PhotoSearchListInteractor()
                let router = PhotoListRouter(with: searchListViewController)
                let presenter = PhotoSearchListPresenter(with: searchListViewController, interactor: interactor, router: router)

                interactor.presenter = presenter
                searchListViewController.presenter = presenter
            }
        }
    }
}
