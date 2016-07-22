//
//  IFDetailsController.swift
//  ifanr
//
//  Created by sys on 16/7/17.
//  Copyright © 2016年 ifanrOrg. All rights reserved.
//

import UIKit
import WebKit
import SnapKit

class IFDetailsController: UIViewController, WKNavigationDelegate, HeaderViewDelegate, UIScrollViewDelegate{

    var model: HomePopularModel?
    var lastPosition: CGFloat = 0
    var headerHeightConstraint: Constraint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.wkWebView)
        self.view.addSubview(self.toolBar)
        self.view.addSubview(self.headerBack)
        
        self.setupLayout()
        
        self.wkWebView.loadRequest(NSURLRequest(URL: NSURL(string: self.model!.link)!))
    }
    
    convenience init(model: HomePopularModel) {
        self.init()
        self.model = model
    }
    
    //MARK:-----Getter and Setter-----
    private lazy var wkWebView: WKWebView = {
        let wkWebView: WKWebView = WKWebView()
        wkWebView.navigationDelegate    = self
        wkWebView.scrollView.delegate   = self
        return wkWebView
    }()
    
    private lazy var toolBar: BottomToolsBar = {
        let toolBar: BottomToolsBar = BottomToolsBar()
        return toolBar
    }()
    
    private lazy var headerBack: HeaderBackView = {
        let headerBack: HeaderBackView = HeaderBackView(title: "玩物志")
        headerBack.delegate = self
        return headerBack
    }()
    //MARK:-----Custom Function-----
    
    private func setupLayout() {
        self.wkWebView.snp_makeConstraints { (make) in
            make.left.right.top.equalTo(self.view);
            make.bottom.equalTo(self.view)
        }
        
        self.toolBar.snp_makeConstraints { (make) in
            make.left.right.bottom.equalTo(self.view)
            make.height.equalTo(40)
        }
        
        self.headerBack.snp_makeConstraints { (make) in
            make.top.left.right.equalTo(self.view)
            self.headerHeightConstraint = make.height.equalTo(50).constraint
        }
    }
    
    //MARK:-----WebView Delegate-----
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.showProgress()
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        self.hiddenProgress()
    }
    
    //MARK:-----HeaderViewDelegate-----
    func backButtonDidClick() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK:-----UIScrollViewDelegate-----
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentPosition: CGFloat = scrollView.contentOffset.y
        if currentPosition - self.lastPosition > 10 {
            
            UIView.animateWithDuration(1, animations: {
                self.headerHeightConstraint?.updateOffset(0)
            })
            self.lastPosition = currentPosition
            
        } else if self.lastPosition - currentPosition > 10 {
            
            UIView.animateWithDuration(1, animations: {
                self.headerHeightConstraint?.updateOffset(50)
            })
            self.lastPosition = currentPosition
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}