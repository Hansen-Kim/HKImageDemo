//
//  PhotoPageViewController.swift
//  HKImageDemo
//
//  Created by 김승한 on 2020/11/19.
//

import UIKit

protocol PhotoPageView: View {
    func scroll(to index: Int)
    
    func reloadData()
    func show(errorMessage: String)
}

class PhotoPageViewController: ViewController {
    internal var presenter: PhotoPagePresenterPrototype!
    
    @IBOutlet weak var pageView: PageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    var isInitialLayoutSubviews: Bool = false
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.isInitialLayoutSubviews {
            self.isInitialLayoutSubviews = true
            self.presenter.viewDidLayoutSubviews()
        }
    }
    
    @IBAction func closeButtonDidTapped(_ sender: UIButton) {
        self.presenter.close()
    }
}

extension PhotoPageViewController: PhotoPageView {
    func scroll(to index: Int) {
        self.pageView.setContentOffset(CGPoint(x: self.pageView.bounds.size.width * CGFloat(index), y: 0.0), animated: false)
    }
    
    func reloadData() {
        self.pageView.reloadData()
    }
    
    func show(errorMessage: String) {
        self.showAlert(with: errorMessage)
    }
}

extension PhotoPageViewController: PageViewDatasource, PageViewDelegate {
    func numberOfContentView(in pageView: PageView) -> UInt {
        return UInt(self.presenter.numberOfContentView)
    }
    
    func isInfinte(in pageView: PageView) -> Bool {
        return false
    }
    
    func pageView(_ pageView: PageView, contentViewAt index: UInt) -> UIView {
        let view: PhotoPageImageView = Bundle.main.load()

        self.presenter.configure(parentView: pageView, photoContainerView: view, at: Int(index))

        return view
    }
    
    func pageView(_ pageView: PageView, didMoveAt index: UInt) {
        self.presenter.currentPageIndex = Int(index)
        
        if self.presenter.numberOfContentView == index + 1, self.presenter.hasMore {
            self.presenter.more()
        }
    }
}
