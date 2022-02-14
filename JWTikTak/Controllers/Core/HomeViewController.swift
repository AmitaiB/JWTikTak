//
//  HomeViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/8/22.
//

import UIKit

// Where the feed shows
class HomeViewController: UIViewController {
    private let hScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .systemRed
        return scrollView
    }()
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(hScrollView)
        setupFeed()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hScrollView.frame = view.bounds
    }
    
    /// Have one horizontal scroll view that can have two paging controllers
    private func setupFeed() {
        
    }
}

