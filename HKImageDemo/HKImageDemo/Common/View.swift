//
//  View.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import UIKit

typealias PreparedHandler = (View, View) -> Void

protocol View: class {
    func route(with identifier: String, preparedHandler: @escaping PreparedHandler)
    func view(with identifier: String) -> View?
    
    func show(to destination: View, routeType: RouteType, animated: Bool)
    func hide(animated: Bool)
}

extension UIViewController {
    open override var next: UIResponder? {
        get { return super.next }
    }
}

extension View where Self: UIViewController {
    func route(with identifier: String, preparedHandler: @escaping PreparedHandler) {
        self.performSegue(withIdentifier: identifier, sender: preparedHandler)
    }
        
    func view(with identifier: String) -> View? {
        return self.storyboard?.instantiateViewController(withIdentifier: identifier) as? View
    }
    
    func show(to destination: View, routeType: RouteType, animated: Bool) {
        switch routeType {
            case .push:
                guard let destinationViewController = destination as? UIViewController else {
                    fatalError("'UIViewController' only supports route of pushType in 'UIViewController'")
                }
                guard let navigationController = self.navigationController else {
                    fatalError("'UIViewController' can't route of pushType without navigationController")
                }
                navigationController.pushViewController(destinationViewController, animated: animated)
            case .present:
                guard let destinationViewController = destination as? UIViewController else {
                    fatalError("'UIViewController' only supports route of presentType in 'UIViewController'")
                }
                self.present(destinationViewController, animated: animated, completion: nil)
            case .custom(let transition):
                if animated {
                    UIView.animate(withDuration: 0.3) {
                        transition(self, destination)
                    }
                } else {
                    transition(self, destination)
                }
        }
    }
    func hide(animated: Bool) {
        if let navigationController = self.navigationController {
            if navigationController.popViewController(animated: animated) == nil, let presentingViewController = self.presentingViewController {
                presentingViewController.dismiss(animated: animated)
            }
        } else if let presentingViewController = self.presentingViewController {
            presentingViewController.dismiss(animated: animated)
        }
    }
}

class ViewController: UIViewController, View {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let preparedHandler = sender as? PreparedHandler,
           let source = segue.source as? View, let destination = segue.destination as? View {
            preparedHandler(source, destination)
        } else {
            fatalError("route destination is not confirmed 'View'")
        }
    }
}
