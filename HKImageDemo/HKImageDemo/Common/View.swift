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
}

extension UIViewController: View {
    func route(with identifier: String, preparedHandler: @escaping PreparedHandler) {
        self.performSegue(withIdentifier: identifier, sender: preparedHandler)
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let preparedHandler = sender as? PreparedHandler {
            preparedHandler(segue.source, segue.destination)
        }
    }
}
