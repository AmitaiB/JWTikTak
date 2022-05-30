//
//  HomeViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/8/22.
//

import UIKit
import Actions

// Where the feed shows
class HomeViewController: UIViewController {
    private let hScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bounces         = false
        scrollView.isPagingEnabled = true
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
        setupHeaderButtons()
        // Starts the app off in the Right Feed (ForYou)
        hScrollView.contentOffset = CGPoint(x: view.width, y: 0)
        hScrollView.delegate = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hScrollView.frame = view.bounds
    }

    // Sets up the "Following" | "For You" control up top
    private let control: UISegmentedControl = {
        let titles = [L10n.following, L10n.forYou]
        let control = UISegmentedControl(items: titles)
        control.selectedSegmentIndex = 1
        
        control.backgroundColor = .systemBackground
        control.selectedSegmentTintColor = .systemMint
        return control
    }()

    private func setupHeaderButtons() {
        control.add(event: .valueChanged) { sender in
            guard let control = sender as? UISegmentedControl else { return }
            let newOffset = CGPoint(x: self.view.width * control.selectedSegmentIndex.CGFloatValue, y: 0)
            self.hScrollView.setContentOffset(newOffset, animated: true)
        }
        
        navigationItem.titleView = control
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
            [PostViewController(model: model, delegate: self)],
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

extension HomeViewController: PostViewControllerDelegate {
    func postViewController(_ viewController: PostViewController, didLike post: PostModel) {
        print(#function)
    }
    
    func postViewController(_ viewController: PostViewController, didSelectProfileFor post: PostModel) {
        let vc = ProfileViewController(user: post.user)
        navigationController?.pushViewController(vc, animated: true)
        print(#function)
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
        let vc = PostViewController(model: model, delegate: self)
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
        let vc = PostViewController(model: model, delegate: self)
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

// MARK: - UIScrollViewDelegate
extension HomeViewController: UIScrollViewDelegate {
    // TODO: The navigation scrolling is fine, but the button push is janky — fix with Combine?
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x < (view.width/2) {
            control.selectedSegmentIndex = 0
        } else if scrollView.contentOffset.x > (view.width/2) {
            control.selectedSegmentIndex = 1
        }
    }
}

/// A `UIPageViewController` with the Tik-Tok-style pageview controller settings.
class PageViewController: UIPageViewController {
    convenience init() {
        self.init(
            transitionStyle: .scroll,
            navigationOrientation: .vertical,
            options: [:])
    }
}
