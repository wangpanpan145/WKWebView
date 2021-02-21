//
//  ViewController.swift
//  WKWebView-Swift
//
//  Created by mac on 2021/2/21.
//

import UIKit
import WebKit
class ViewController: UIViewController {
    //懒加载属性webView
    lazy var webView: WKWebView = {
        var webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.view.addSubview(webView)
        return webView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = "https://www.baidu.com"
        webView.load(URLRequest.init(url: URL.init(string: url)!))
    }
}



