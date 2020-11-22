//
//  PhotoListViewController.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import UIKit

protocol PhotoListView: class, View {
    func willStartFetching()
    func didFinishFetched()
    
    func scroll(to indexPath: IndexPath)
    func reloadData()
    func show(errorMessage: String)
}

class PhotoListViewController: ViewController {
    internal var presenter: PhotoListPresenterPrototype!
    
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    
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
    
    func didFinishFetched() {
        self.indicatorView.stopAnimating()
    }
 
    func reloadData() {
        UIView.performWithoutAnimation {
            // Search Results에서 상세 페이지 확인 후 reload될 때 상세 페이지로 넘어 갔었던 indexPath로 이동하는 문제 수정
            let contentOffset = self.tableView.contentOffset
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
            self.tableView.setContentOffset(contentOffset, animated: false)
        }

        self.tableView.isHidden = false
        self.errorLabel.isHidden = true
        self.reloadButton.isHidden = true
    }

    func show(errorMessage: String) {
        self.errorLabel.text = errorMessage

        self.tableView.isHidden = true
        self.errorLabel.isHidden = false
        self.reloadButton.isHidden = false
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.presenter.heightForRow(parentView: tableView, at: indexPath)
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.presenter.heightForRow(parentView: tableView, at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.presenter.didSelectedRow(at: indexPath)
    }
//            
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
