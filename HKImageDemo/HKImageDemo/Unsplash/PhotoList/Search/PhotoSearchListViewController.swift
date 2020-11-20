//
//  PhotoSearchListViewController.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import UIKit

protocol PhotoSearchListView: PhotoListView {
    var query: String { get set }
}

class PhotoSearchListViewController: PhotoListViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // iOS 12.X 에서 검색창을 덮어버리는 문제 수정
        self.edgesForExtendedLayout = []
    }
    
    private var searchPresenter: PhotoSearchListPresenter? {
        return self.presenter as? PhotoSearchListPresenter
    }
    
    var query: String = "" {
        didSet {
            self.scheduledNotifyQueryChanged()
        }
    }
    private var notifyTimer: Timer? {
        willSet {
            self.notifyTimer?.invalidate()
        }
    }
    func scheduledNotifyQueryChanged() {
        self.notifyTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.searchPresenter?.query = self.query
        }
    }
}

extension PhotoSearchListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.query = searchController.searchBar.text ?? ""
    }
}
