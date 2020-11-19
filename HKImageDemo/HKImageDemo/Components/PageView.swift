//
//  PageView.swift
//  HKImageDemo
//
//  Created by Seunghan Kim on 2020/11/18.
//

import UIKit

@objc protocol PageViewDatasource: class {
    func numberOfContentView(in pageView: PageView) -> UInt
    func pageView(_ pageView: PageView, contentViewAt index: UInt) -> UIView
    func isInfinte(in pageView: PageView) -> Bool
}

@objc protocol PageViewDelegate: UIScrollViewDelegate {
    func pageView(_ pageView: PageView, willShowContentView contentView: UIView, at index: UInt)
    func pageView(_ pageView: PageView, didShowContentView contentView: UIView, at index: UInt)
    
    func pageView(_ pageView: PageView, willHideContentView contentView: UIView, at index: UInt)
    func pageView(_ pageView: PageView, didHideContentView contentView: UIView, at index: UInt)
    
    func pageView(_ pageView: PageView, didMoveAt index: UInt)
    func pageView(_ pageView: PageView, didChangedWeight weight: CGFloat, contentView: UIView)
}

class PageView: UIScrollView {
    enum PageViewError: Error {
        case contentViewIsEmpty(index: UInt)
    }
    
    @IBOutlet weak var datasource: PageViewDatasource?
    @IBOutlet weak var pageViewDelegate: PageViewDelegate? {
        get { return self.delegate as? PageViewDelegate }
        set { self.delegate = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInitialize()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.commonInitialize()
    }
    
    override var isPagingEnabled: Bool {
        get { return super.isPagingEnabled }

        @available(*, unavailable)
        set {
            #if DEBUG
            fatalError("PageView must use paging")
            #endif
        }
    }
    override var contentSize: CGSize {
        get { return super.contentSize }
        
        @available(*, unavailable)
        set {
            #if DEBUG
            fatalError("PageView cannot set contentSize - autoSizing")
            #endif
        }
    }
    override var contentInset: UIEdgeInsets {
        get { return super.contentInset }
        
        @available(*, unavailable)
        set {
            #if DEBUG
            fatalError("PageView cannot set contentInset - autoSizing")
            #endif
        }
    }
    
    var currentIndex: UInt {
        get {
            let bounds = self.bounds
            return PageView.logicalIndex(index: PageView.absoluteIndex(x: bounds.origin.x, width: bounds.size.width), count: Int(self.numberOfContentView))
        }
    }
    
    var numberOfContentView: UInt {
        self.datasource?.numberOfContentView(in: self) ?? 0
    }
    var isInfinite: Bool {
        self.datasource?.isInfinte(in: self) ?? false
    }
    
    func contentView(at index: UInt) throws -> UIView? {
        guard let contentView = self.datasource?.pageView(self, contentViewAt: index) else {
            throw PageViewError.contentViewIsEmpty(index: index)
        }
        return contentView
    }
    
    func reloadData() {
        let bounds = self.bounds
        if self.isInfinite {
            super.contentSize = CGSize(width: .greatestFiniteMagnitude, height: bounds.size.height)
            super.contentInset = UIEdgeInsets(top: 0.0, left: .greatestFiniteMagnitude, bottom: 0.0, right: 0.0)
        } else {
            let numberOfContentViews = self.numberOfContentView
            let index = self.currentIndex
            
            super.contentSize = CGSize(width: bounds.size.width * CGFloat(numberOfContentViews), height: bounds.size.height)
            super.contentInset = .zero
            self.contentOffset = CGPoint(x: bounds.size.width * CGFloat(index), y: 0.0)
        }
        
        DispatchQueue.main.async {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
    }
    
    // MARK - private
    private var containerView: UIView!
    private var _currentIndex: UInt = UInt.max

    private static func absoluteIndex(x: CGFloat, width: CGFloat) -> Int {
        guard width > 0 else { return 0 }
        return Int(floor(x / width))
    }
    
    private static func logicalIndex(index: Int, count: Int) -> UInt {
        guard count > 0 else { return 0 }
        return UInt((count + (index % count)) % count)
    }
    
    private func commonInitialize() {
        let containerView = UIView(frame: self.bounds)
        containerView.backgroundColor = .clear
        
        self.containerView = containerView
        super.isPagingEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        let contentWidth = bounds.size.width
        
        let numberOfContentView = Int(self.numberOfContentView)
        guard bounds.size.width > 0.0, numberOfContentView > 0 else {
            return
        }
        
        self.containerView.frame = bounds
        var visibleViews = Set<UIView>()
        
        var absoluteIndex = PageView.absoluteIndex(x: bounds.origin.x, width: contentWidth)
        while true {
            var frame = bounds
            frame.origin.x = CGFloat(absoluteIndex) * contentWidth
            
            guard bounds.intersects(frame) else { break }
            
            let logicalIndex = PageView.logicalIndex(index: absoluteIndex, count: numberOfContentView)
            do {
                if let view = try self.contentView(at: logicalIndex) {
                    if view.superview !== self.containerView {
                        self.pageViewDelegate?.pageView(self, willShowContentView: view, at: logicalIndex)
                        self.containerView.addSubview(view)
                        self.pageViewDelegate?.pageView(self, didShowContentView: view, at: logicalIndex)
                    }
                    view.frame = frame
                    visibleViews.insert(view)
                    
                    let weight = 1.0 - min(abs(bounds.midX - view.center.x) / contentWidth, 1.0)
                    self.pageViewDelegate?.pageView(self, didChangedWeight: weight, contentView: view)
                }
            } catch let exception {
                self.log(message: "exception : \(exception)")
            }
            
            absoluteIndex += 1
        }
        
        self.subviews
            .filter { !visibleViews.contains($0) }
            .forEach {
                let index = PageView.logicalIndex(index: PageView.absoluteIndex(x: $0.frame.origin.x, width: contentWidth), count: numberOfContentView)
                self.pageViewDelegate?.pageView(self, willHideContentView: $0, at: index)
                $0.removeFromSuperview()
                self.pageViewDelegate?.pageView(self, didHideContentView: $0, at: index)
            }
        
        self.containerView.bounds = bounds
        
        let currentIndex = self.currentIndex
        if currentIndex != self._currentIndex {
            self._currentIndex = currentIndex
            self.pageViewDelegate?.pageView(self, didMoveAt: currentIndex)
        }
    }
}

extension PageView: Loggable { }

extension PageViewDelegate {
    func pageView(_ pageView: PageView, willShowContentView contentView: UIView, at index: UInt) {
        
    }
    func pageView(_ pageView: PageView, didShowContentView contentView: UIView, at index: UInt) {
        
    }
    
    func pageView(_ pageView: PageView, willHideContentView contentView: UIView, at index: UInt) {
        
    }
    func pageView(_ pageView: PageView, didHideContentView contentView: UIView, at index: UInt) {
        
    }
    
    func pageView(_ pageView: PageView, didMoveAt index: UInt) {
        
    }
    func pageView(_ pageView: PageView, didChangedWeight weight: CGFloat, contentView: UIView) {
        
    }
}
