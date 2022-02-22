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
        
        configureMockModels()
        setupSearchBar()
        setupCollectionView()
    }
    
    private func setupSearchBar() {
        navigationItem.titleView = searchBar
        searchBar.delegate = self
    }
    
    // TODO: MOCK Cells
    private func configureMockModels() {
        let bannerCell = ExploreCell.banner(
            viewModel: ExploreBannerViewModel(
                image: Asset.test.image,
                title: "Foo",
                handler: {print("nil")}
            )
        )
        
        let postCell = ExploreCell.post(
            viewModel: ExplorePostViewModel(
                thumbnailImage: Asset.test.image,
                caption: "Crazy cool post!",
                handler: nil
            )
        )
        
        let userCell = ExploreCell.user(
            viewModel: ExploreUserViewModel(
                profilePicURL: nil,
                username: "The Dude",
                followerCount: 613,
                handler: nil
            )
        )
        
        let hashtagCell = ExploreCell.hashtag(
            viewModel: ExploreHashtagViewModel(
                icon: UIImage(systemName: L10n.SFSymbol.camera),
                text: "#bestPosts #truth",
                count: 42,
                handler: nil
            )
        )
        
        // Banners
        sections += [ExploreSection(
            type:  .banners,
            cells: Array(repeating: bannerCell, count: 50))]
            
        // Trending Posts
        sections += [ExploreSection(
            type:  .trending,
            cells: Array(repeating: postCell, count: 50))]
        
        // Users
        sections += [ExploreSection(
            type:  .users,
            cells: Array(repeating: userCell, count: 50))]
                
        // Trending Hashtags
        sections += [ExploreSection(
            type:  .trendingHashtags,
            cells: Array(repeating: hashtagCell, count: 50))]
        
        // Recommended
        sections += [ExploreSection(
            type:  .recommended,
            cells: Array(repeating: postCell, count: 50))]
        

        // Popular
        sections += [ExploreSection(
            type:  .popular,
            cells: Array(repeating: postCell, count: 50))]
        
        // New
        sections += [ExploreSection(
            type:  .new,
            cells: Array(repeating: postCell, count: 50))]
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
        
    typealias Layouts = ExploreSectionLayoutProvider
    lazy var layoutForSection: UICollectionViewCompositionalLayoutSectionProvider = { section, _ -> NSCollectionLayoutSection? in
        let sectionType = self.sections[section].type
        
        
        var itemWidth, itemHeight, groupWidth, groupHeight: NSCollectionLayoutDimension!
        var itemInsets: NSDirectionalEdgeInsets = .zero

        switch sectionType {
            case .banners:          return Layouts.bannerSectionLayout
            case .users:            return Layouts.usersSectionLayout
            case .trendingHashtags: return Layouts.trendingHashtagsSectionLayout
            case .popular:          return Layouts.popularPostsSectionLayout
            case .trending, .recommended, .new: // various flavors of posts
                return Layouts.postsSectionLayout
        }
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
                break
            case .post(viewModel: let viewModel):
                break
            case .hashtag(viewModel: let viewModel):
                break
            case .user(viewModel: let viewModel):
                break
        }
    }
}

extension ExploreViewController: UISearchBarDelegate {
    
}
