//
//  ExploreViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import Reusable
import RandomColor
import SnapKit
import Actions

class ExploreViewController: UIViewController {
    private let searchBar: UISearchBar = {
        let bar = UISearchBar()
        bar.placeholder         = "Search ..."
        bar.layer.cornerRadius  = 8
        bar.layer.masksToBounds = true
        return bar
    }()
    
    private var collectionView: UICollectionView?
    fileprivate var sections = [ExploreSection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        ExploreDataManager.shared.delegate = self
        configureMockModels()
        setupSearchBar()
        setupCollectionView()
    }
    
    private func setupSearchBar() {
        navigationItem.titleView = searchBar
        searchBar.delegate = self
    }
    
    private func configureRefreshControl () {
        // Add the refresh control to your UIScrollView object.
        collectionView?.refreshControl = UIRefreshControl()
        collectionView?.refreshControl?.add(event: .valueChanged) {
            self.collectionView?.reloadData()
            self.collectionView?.refreshControl?.endRefreshing()
        }
            
//            .addTarget(self, action:
//                                                    #selector(handleRefreshControl),
//                                                  for: .valueChanged)
    }
    
//    @MainActor
//    @objc func handleRefreshControl() {
//        // Update your content…
//        
//        // Dismiss the refresh control.
//            self.myScrollingView.refreshControl?.endRefreshing()
//    }
    
    // TODO: MOCK Cells
    private func configureMockModels() {
        let mockResponse = ExploreDataManager.shared
        
        // Banners
        sections += [ExploreSection(
            type:  .banners,
            cells: mockResponse.getExploreBanners()
                .map { ExploreCell.banner(viewModel: $0) }
        )]
            
        // Trending Posts
        sections += [ExploreSection(
            type:  .trending,
            cells: mockResponse.getExploreTrending()
                .map { ExploreCell.post(viewModel: $0) }
        )]
        
        // Users
        sections += [ExploreSection(
            type:  .users,
            cells: mockResponse.getExploreCreators()
                .map { ExploreCell.user(viewModel: $0) }
        )]
                
        // Hashtags
        sections += [ExploreSection(
            type:  .hashtags,
            cells: mockResponse.getExploreHashtags()
                .map { ExploreCell.hashtag(viewModel: $0) }
        )]
        
        // Recommended
        sections += [ExploreSection(
            type:  .recommended,
            cells: mockResponse.getExploreRecommended()
                .map { ExploreCell.post(viewModel: $0) }
        )]

        // Popular
        sections += [ExploreSection(
            type:  .popular,
            cells: mockResponse.getExplorePopular()
                .map { ExploreCell.post(viewModel: $0) }
        )]
        
        // Recent Posts
        sections += [ExploreSection(
            type:  .recent,
            cells: mockResponse.getExploreRecent()
                .map { ExploreCell.post(viewModel: $0) }
            )]
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: layoutForSection)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate   = self
        collectionView.dataSource = self
        
        collectionView.register(cellType: ExploreBannerCollectionViewCell.self)
        collectionView.register(cellType: ExplorePostCollectionViewCell.self)
        collectionView.register(cellType: ExploreUserCollectionViewCell.self)
        collectionView.register(cellType: ExploreHashtagCollectionViewCell.self)
        
        collectionView.backgroundColor = .systemYellow
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        self.collectionView = collectionView
    }
    
    // MARK: - Section Layouts
    
    typealias Layouts = ExploreSectionLayoutProvider
    lazy var layoutForSection: UICollectionViewCompositionalLayoutSectionProvider = { section, _ -> NSCollectionLayoutSection? in
        let sectionType = self.sections[section].type
        
        
        var itemWidth, itemHeight, groupWidth, groupHeight: NSCollectionLayoutDimension!
        var itemInsets: NSDirectionalEdgeInsets = .zero
        
        switch sectionType {
            case .banners:  return Layouts.bannerSectionLayout
            case .users:    return Layouts.usersSectionLayout
            case .hashtags: return Layouts.trendingHashtagsSectionLayout
            case .popular:  return Layouts.popularPostsSectionLayout
            case .trending, .recommended, .recent: // various flavors of posts ↲
                return Layouts.postsSectionLayout
        }
    }
}


// MARK: UISearchBarDelegate
extension ExploreViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, action: { _ in
            searchBar.text = nil
            searchBar.resignFirstResponder()
            self.navigationItem.rightBarButtonItem = nil
        })
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        navigationItem.rightBarButtonItem = nil
        searchBar.resignFirstResponder()
    }
}

extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sections[section].cells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = sections[indexPath.section].cells[indexPath.row]
        
        let cell: (UICollectionViewCell & ViewModelConfigurable)!
        
        switch model {
            case .banner(viewModel: let viewModel):
                cell = collectionView.dequeueReusableCell(
                    for: indexPath, cellType: ExploreBannerCollectionViewCell.self)
                cell.configure(with: viewModel)
            case .post(viewModel: let viewModel):
                cell = collectionView.dequeueReusableCell(
                    for: indexPath, cellType: ExplorePostCollectionViewCell.self)
                cell.configure(with: viewModel)
            case .hashtag(viewModel: let viewModel):
                cell = collectionView.dequeueReusableCell(
                    for: indexPath, cellType: ExploreHashtagCollectionViewCell.self)
                cell.configure(with: viewModel)
            case .user(viewModel: let viewModel):
                cell = collectionView.dequeueReusableCell(
                    for: indexPath, cellType: ExploreUserCollectionViewCell.self)
                cell.configure(with: viewModel)
        }
        
        cell.backgroundColor = randomColor()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        
        let model = sections[indexPath.section].cells[indexPath.row]
        
        switch model {
            case .banner(viewModel: let viewModel):
                viewModel.handler?()
            case .post(viewModel: let viewModel):
                viewModel.handler?()
            case .hashtag(viewModel: let viewModel):
                viewModel.handler?()
            case .user(viewModel: let viewModel):
                viewModel.handler?()
        }
    }
}

extension ExploreViewController: ExploreDataManagerDelegate {
    @MainActor
    func pushViewController(_ viewController: UIViewController) {
        HapticsManager.shared.vibrateForSelection()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func didTapHashtag(_ hashtag: String) {
        HapticsManager.shared.vibrateForSelection()
        searchBar.text = hashtag
        searchBar.becomeFirstResponder()
    }
}
