//
//  HomeViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/8/22.
//

import UIKit

// Where the feed shows
class HomeViewController: UIViewController {
    fileprivate let hScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces         = false
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = .systemRed
        return scrollView
    }()
    
    private var forYouPosts    = PostModel.mockModels()
    private var followingPosts = PostModel.mockModels()
    
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
        let pageViewController: UIPageViewController
        let xPos: CGFloat
        let model: PostModel?
        
        if type == .following {
            pageViewController = followingPageViewController
            xPos = 0
            model = followingPosts.first
        } else {
            pageViewController = forYouPageViewController
            xPos = view.width
            model = forYouPosts.first
        }
        
        guard let model = model else { return }
         
        pageViewController.setViewControllers(
            [PostViewController(model: model)],
            direction: .forward,
            animated: true,
            completion: nil)
        
        pageViewController.dataSource = self
        
        hScrollView.addSubview(pageViewController.view)
        // size is a standard device size, position is origin. SECOND feed ('right' side).
        pageViewController.view.frame = CGRect(x: xPos,
                                               y: 0,
                                               width: hScrollView.width,
                                               height: hScrollView.height)
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
    }
}

// MARK: - UIPageViewControllerDataSource
extension HomeViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        // Swiping down to scroll up (right?)
        
        guard let currentPost = (viewController as? PostViewController)?.model
        else { return nil }
        
        guard let index = currentPosts.firstIndex(where: {$0 == currentPost})
        else { return nil }
        
        // If we are at the beginning of the feed, there is no prior post, exit early
        if index == 0 { return nil }
        
        let priorIndex = index - 1
        let model = currentPosts[priorIndex]
        let vc = PostViewController(model: model)
        return vc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        // Swiping up to scroll down (right?)
        guard let currentPost = (viewController as? PostViewController)?.model
        else { return nil }
        
        guard let index = currentPosts.firstIndex(where: {$0 == currentPost})
        else { return nil }
        
        // Only continue if there is at least one more subsequent post.
        guard index < (currentPosts.count - 1) else { return nil }
        
        let nextIndex = index + 1
        let model = currentPosts[nextIndex]
        let vc = PostViewController(model: model)
        return vc
    }
    
    /// Returns the current feed inferred from the onscreen content
    var currentFeed: FeedType {
        (hScrollView.contentOffset.x == 0) ?
        .following : .forYou
    }
        
    var currentPosts: [PostModel] {
        (currentFeed == .forYou) ? forYouPosts : followingPosts
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
