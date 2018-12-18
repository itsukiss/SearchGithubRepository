//
//  WebViewController.swift
//  SearchGithubRepository
//
//  Created by 田中 厳貴 on 2018/12/18.
//  Copyright © 2018年 田中 厳貴. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    private var url: URL!
    
    static func instantiate(url: URL) -> WebViewController {
        let vc = UIStoryboard(name: "WebViewController", bundle: nil).instantiateInitialViewController() as! WebViewController
        vc.url = url
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: url))
    }
}
