//
//  Presenter.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import Foundation

protocol Presenter {
    func viewDidLoad()
    
    func viewWillAppear()
    func viewWillDisappear()
}

extension Presenter {
    func viewDidLoad() { }

    func viewWillAppear() { }
    func viewWillDisappear() { }
}
