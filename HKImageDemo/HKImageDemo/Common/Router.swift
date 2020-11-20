//
//  Router.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import UIKit

enum RouteType {
    case push
    case present
    case custom(transition: (View, View) -> Void)
}

protocol Router {
    var view: View? { get }
    
    func show(with identifier: String, preparedHandler: @escaping PreparedHandler)
    func show(with identifier: String, routeType: RouteType, animated: Bool)
}

extension Router {
    func show(with identifier: String, preparedHandler: @escaping PreparedHandler) {
        self.view?.route(with: identifier, preparedHandler: preparedHandler)
    }
    
    func show(with identifier: String, routeType: RouteType, animated: Bool) {
        guard let destination = self.view?.view(with: identifier) else { return }
        self.view?.show(to: destination, routeType: routeType, animated: animated)
    }
}
