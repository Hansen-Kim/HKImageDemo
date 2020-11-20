//
//  PhotoListViewController.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import UIKit

protocol PhotoListView: class, View {
    func willStartFetching()
    func didFinishFetching()
    
    func scroll(to indexPath: IndexPath)
    func reloadData()
    func show(errorMessage: String)
}

class PhotoListViewController: UIViewController {
    var presenter: PhotoListPresenterPrototype!
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presenter.viewDidLoad()
    }
    
    @IBAction func retryButtonDidTapped(_ sender: UIButton) {
        self.presenter.reload()
    }
}

extension PhotoListViewController: PhotoListView {
    func willStartFetching() {
        self.indicatorView.startAnimating()
    }
    
    func didFinishFetching() {
        self.indicatorView.stopAnimating()
    }
 
    func reloadData() {
        self.tableView.isHidden = false
        self.tableView.reloadData()
    }

    func show(errorMessage: String) {
        self.tableView.isHidden = true
    }

    func scroll(to indexPath: IndexPath) {
        self.tableView.scrollToRow(at: indexPath, at: .none, animated: false)
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
        
        self.presenter.configure(parentView: tableView, photoContainerView: cell, at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter.didSelectedRow(at: indexPath)
    }
        
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.checkScrollToLastContent(of: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        _ = decelerate ? nil : self.checkScrollToLastContent(of: scrollView)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.checkScrollToLastContent(of: scrollView)
    }
    
    func checkScrollToLastContent(of scrollView: UIScrollView) {
        if (scrollView.contentSize.height - scrollView.bounds.height) < scrollView.contentOffset.y, self.presenter.hasMore {
            DispatchQueue.main.async {
                self.presenter.more()
            }
        }
    }
}
