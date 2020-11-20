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

protocol RouteIdentifier {
    var identifier: String { get }
}

protocol Router {
    var view: View? { get }
    
    func show(with identifier: RouteIdentifier, preparedHandler: @escaping PreparedHandler)
    func show(with identifier: RouteIdentifier, routeType: RouteType, animated: Bool, preparedHandler: @escaping PreparedHandler)
}

extension Router {
    func show(with identifier: RouteIdentifier, preparedHandler: @escaping PreparedHandler) {
        self.view?.route(with: identifier.identifier, preparedHandler: preparedHandler)
    }
    
    func show(with identifier: RouteIdentifier, routeType: RouteType, animated: Bool, preparedHandler: @escaping PreparedHandler) {
        guard let destination = self.view?.view(with: identifier.identifier) else { return }
        
        if let source = self.view {
            preparedHandler(source, destination)
            self.view?.show(to: destination, routeType: routeType, animated: animated)
        }
    }
}

extension String: RouteIdentifier {
    var identifier: String { return self }
}

struct SegueIdentifier<T>: RouteIdentifier where T: UIViewController {
    let identifier: String
    init(with type: T.Type = T.self) {
        self.identifier = String(describing: T.self)
    }
}
