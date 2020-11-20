//
//  UnsplashInitialRouter.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/20.
//

import UIKit

protocol UnsplashInitialRouterPrototype {
    func showMainList()
}

struct UnsplashInitialRouter: Router {
    private var navigationController: UINavigationController
    var view: View? {
        return self.navigationController
    }
    
    init(with navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func showMainList() {
        let transition: (View, View) -> Void = { (source, destination) in
            if let navigationController = source as? UINavigationController,
               let mainListViewController = destination as? PhotoMainListViewController {
                navigationController.navigationBar
                navigationController.setNavigationBarHidden(false, animated: true)
                navigationController.viewControllers = [mainListViewController]
            }
        }
        
        self.show(with: SegueIdentifier<PhotoMainListViewController>(),
                  routeType: .custom(transition: transition), animated: false) { (_, destination) in
            if let mainListViewController = destination as? PhotoMainListViewController {
                let interactor = PhotoMainListInteractor()
                let router = PhotoListRouter(with: mainListViewController)
                let presenter = PhotoListPresenter(with: mainListViewController, interactor: interactor, router: router)

                interactor.presenter = presenter
                mainListViewController.presenter = presenter
            }
        }
    }
}

extension UINavigationController: View { }
