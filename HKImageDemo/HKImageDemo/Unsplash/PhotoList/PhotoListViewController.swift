//
//  PhotoListViewController.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import UIKit

protocol PhotoListView: class {
    func willStartFetching()
    func didFinishFetching()
}

class PhotoListViewController: UIViewController {
    var presenter: PhotoListPresenterPrototype!
    
    @IBOutlet var indicatorView: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter.viewDidLoad()
    }
}

extension PhotoListViewController: PhotoListView {
    func willStartFetching() {
        self.indicatorView.startAnimating()
    }
    
    func didFinishFetching() {
        self.indicatorView.stopAnimating()
        self.tableView.reloadData()
    }
}

extension PhotoListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.presenter.numberOfRow(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PhotoListTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        
        self.presenter.configure(photoContainerView: cell, at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter.didSelectedRow(at: indexPath)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let targetContentOffset = targetContentOffset.pointee
        if (scrollView.contentSize.height - scrollView.bounds.height) < targetContentOffset.y, self.presenter.hasMore {
            self.presenter.more()
        }
    }
}
