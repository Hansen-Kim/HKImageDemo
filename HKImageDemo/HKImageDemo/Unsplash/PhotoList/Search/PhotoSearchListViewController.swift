//
//  PhotoSearchListViewController.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import Foundation

class PhotoSearchListViewController: PhotoListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // iOS 12.X 에서 검색창을 덮어버리는 문제 수정
        self.edgesForExtendedLayout = []
    }
}
