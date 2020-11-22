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
    @objc optional func pageView(_ pageView: PageView, willShowContentView contentView: UIView, at index: UInt)
    @objc optional func pageView(_ pageView: PageView, didShowContentView contentView: UIView, at index: UInt)
    
    @objc optional func pageView(_ pageView: PageView, willHideContentView contentView: UIView, at index: UInt)
    @objc optional func pageView(_ pageView: PageView, didHideContentView contentView: UIView, at index: UInt)
    
    @objc optional func pageView(_ pageView: PageView, didMoveAt index: UInt)
    @objc optional func pageView(_ pageView: PageView, didChangedWeight weight: CGFloat, contentView: UIView)
}

class PageView: UIScrollView {
    enum PageViewError: Error {
        case contentViewIsEmpty(index: UInt)
    }
    
    private struct DelegationResponsable {
        var responseWillShowContentView: Bool = false
        var responseDidShowContentView: Bool = false
        var responseWillHideContentView: Bool = false
        var responseDidHideContentView: Bool = false
        var responseDidMoveAtIndex: Bool = false
        var responseDidChangedWeight: Bool = false
    }
    private var delegationResponsable = DelegationResponsable()
    
    @IBOutlet weak var datasource: PageViewDatasource?
    @IBOutlet weak var pageViewDelegate: PageViewDelegate? {
        get { return self.delegate as? PageViewDelegate }
        set {
            self.delegationResponsable.responseWillShowContentView = newValue?.responds(to: #selector(PageViewDelegate.pageView(_:willShowContentView:at:))) ?? false
            self.delegationResponsable.responseDidShowContentView = newValue?.responds(to: #selector(PageViewDelegate.pageView(_:didShowContentView:at:))) ?? false
            self.delegationResponsable.responseWillHideContentView = newValue?.responds(to: #selector(PageViewDelegate.pageView(_:willHideContentView:at:))) ?? false
            self.delegationResponsable.responseDidHideContentView = newValue?.responds(to: #selector(PageViewDelegate.pageView(_:didHideContentView:at:))) ?? false
            self.delegationResponsable.responseDidMoveAtIndex = newValue?.responds(to: #selector(PageViewDelegate.pageView(_:didMoveAt:))) ?? false
            self.delegationResponsable.responseDidChangedWeight = newValue?.responds(to: #selector(PageViewDelegate.pageView(_:didChangedWeight:contentView:))) ?? false
            self.delegate = newValue
        }
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
            let numberOfContentView = Int(self.numberOfContentView)
            let absoluteIndex = PageView.absoluteIndex(x: bounds.origin.x, width: bounds.size.width)
            return self.isInfinite ? UInt(PageView.logicalIndex(index: absoluteIndex, count: numberOfContentView)) : UInt(max(0, min(absoluteIndex, numberOfContentView - 1)))
        }
    }
    
    var numberOfContentView: UInt {
        self.datasource?.numberOfContentView(in: self) ?? 0
    }
    var isInfinite: Bool {
        self.datasource?.isInfinte(in: self) ?? false
    }

    private var visibleViews: [UInt: UIView] = [:]
    private func visibleView(at index: UInt) -> UIView? {
        return self.visibleViews[index]
    }
    private func add(visibleView: UIView, at index: UInt) {
        self.visibleViews[index] = visibleView
    }
    
    func contentView(at index: UInt) throws -> UIView? {
        guard let contentView = self.visibleView(at: index) ?? self.datasource?.pageView(self, contentViewAt: index) else {
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
            self.visibleViews.removeAll()

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
    
    private static func logicalIndex(index: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return (count + (index % count)) % count
    }
    
    private func commonInitialize() {
        let containerView = UIView(frame: self.bounds)
        containerView.backgroundColor = .clear
        
        self.containerView = containerView
        self.addSubview(containerView)
        super.isPagingEnabled = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        let contentWidth = bounds.size.width
        
        let numberOfContentView = Int(self.numberOfContentView)
        guard bounds.size.width > 0.0, numberOfContentView > 0 else {
            self.containerView.subviews.forEach { $0.removeFromSuperview() }
            return
        }
        
        self.containerView.frame = bounds
        var visibleViews = Set<UIView>()
        
        var absoluteIndex = PageView.absoluteIndex(x: bounds.origin.x, width: contentWidth)
        while true {
            var frame = bounds
            frame.origin.x = CGFloat(absoluteIndex) * contentWidth
            
            guard bounds.intersects(frame) else { break }
            
            let logicalIndex = self.isInfinite ? PageView.logicalIndex(index: absoluteIndex, count: numberOfContentView) : absoluteIndex
            do {
                guard (0..<numberOfContentView).contains(logicalIndex) else {
                    absoluteIndex += 1
                    if logicalIndex < numberOfContentView {
                        continue
                    } else {
                        break
                    }
                }
                let logicalIndex = UInt(logicalIndex)
                
                if let view = try self.contentView(at: logicalIndex) {
                    if view.superview !== self.containerView {
                        self.add(visibleView: view, at: logicalIndex)
                        _ = self.delegationResponsable.responseWillShowContentView ?
                            self.pageViewDelegate?.pageView!(self, willShowContentView: view, at: logicalIndex) : nil
                        self.containerView.addSubview(view)
                        _ = self.delegationResponsable.responseDidShowContentView ? self.pageViewDelegate?.pageView!(self, didShowContentView: view, at: logicalIndex) : nil
                    }
                    view.frame = frame
                    visibleViews.insert(view)
                    
                    if self.delegationResponsable.responseDidChangedWeight {
                        let weight = 1.0 - min(abs(bounds.midX - view.center.x) / contentWidth, 1.0)
                        self.pageViewDelegate?.pageView!(self, didChangedWeight: weight, contentView: view)
                    }
                }
            } catch let exception {
                self.log(message: "exception : \(exception)")
            }
            
            absoluteIndex += 1
        }
        
        self.visibleViews
            .filter { !visibleViews.contains($1) }
            .forEach {
                _ = self.delegationResponsable.responseWillHideContentView ? self.pageViewDelegate?.pageView!(self, willHideContentView: $1, at: $0) : nil
                $1.removeFromSuperview()
                _ = self.delegationResponsable.responseDidHideContentView ? self.pageViewDelegate?.pageView!(self, didHideContentView: $1, at: $0) : nil
            }
        
        self.containerView.bounds = bounds
        
        let currentIndex = self.currentIndex
        if currentIndex != self._currentIndex, self.delegationResponsable.responseDidMoveAtIndex {
            self._currentIndex = currentIndex
            self.pageViewDelegate?.pageView!(self, didMoveAt: currentIndex)
        }
    }
}

extension PageView: Loggable { }
