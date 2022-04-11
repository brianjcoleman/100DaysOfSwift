//
//  WebViewController.swift
//  Project16
//
//  Created by Brian Coleman on 2022-04-11.
//

import Foundation
import WebKit
import UIKit

class WebViewController: UIViewController, WKNavigationDelegate {
    var webView: WKWebView!
    var countryName: String?
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard var countryName = countryName else { return }
        
        countryName = countryName.replacingOccurrences(of: ".", with: "")
        countryName = countryName.replacingOccurrences(of: " ", with: "_")
        
        let urlString = "https://en.wikipedia.org/wiki/\(String(describing: countryName))"
        print(urlString)

        if let url = URL(string: urlString){
            webView.load(URLRequest(url: url))
        }
    }
}
