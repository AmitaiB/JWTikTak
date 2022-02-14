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
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces         = false
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .systemRed
        return scrollView
    }()
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(hScrollView)
        setupFeeds()
        // Starts the app off in the Right Feed (ForYou)
        hScrollView.contentOffset = CGPoint(x: view.width, y: 0)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hScrollView.frame = view.bounds
    }
    
    /// Have one horizontal scroll view that can have two paging controllers
    private func setupFeeds() {
        // This will allow paging 'left' and 'right' between the two page view controllers (of equal width, side by side).
        hScrollView.contentSize = CGSize(width: view.width * 2, height: view.height)
        
        [.following, .forYou]
            .forEach { setupFeed(type: $0) }
    }
    
    /// On the Right Side. 'Default' view.
    let forYouPageViewController    = PageViewController()
    /// On the Left Side.
    let followingPageViewController = PageViewController()

    enum FeedType { case forYou, following }
    
    private func setupFeed(type: FeedType) {
        let pageViewController = type == .following ?
        followingPageViewController : forYouPageViewController
        
        let mockVC = UIViewController()
        mockVC.view.backgroundColor = .blue
        
        pageViewController.setViewControllers(
            [mockVC],
            direction: .forward,
            animated: true,
            completion: nil)
        
        pageViewController.dataSource = self
        
        hScrollView.addSubview(pageViewController.view)
        // size is a standard device size, position is origin. SECOND feed ('right' side).
        let xPos = type == .following ? 0 : view.width
        pageViewController.view.frame = CGRect(x: xPos,
                                               y: 0,
                                               width: hScrollView.width,
                                               height: hScrollView.height)
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
    }
}

extension HomeViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let randoVC = UIViewController()
        randoVC.view.backgroundColor = [.red, .gray, .green].randomElement()
        return randoVC
    }
}

class PageViewController: UIPageViewController {
    convenience init() {
        self.init(
            transitionStyle: .scroll,
            navigationOrientation: .vertical,
            options: [:])
    }
}
