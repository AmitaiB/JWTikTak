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
        
        configureModels()
        setupSearchBar()
        setupCollectionView()
    }
    
    private func setupSearchBar() {
        navigationItem.titleView = searchBar
        searchBar.delegate = self
    }
    
    // TODO: MOCK Cells
    private func configureModels() {
        let cell = ExploreCell.banner(
            viewModel: ExploreBannerViewModel(
                image: nil,
                title: "Foo", handler: {
                    
                }
            )
        )
                    
        sections = [ExploreSection(
            type: .banners,
            cells: Array(repeating: cell, count: 100)
        )]
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout(sectionProvider: layoutForSection)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate   = self
        collectionView.dataSource = self
        collectionView.register(cellType: Dummy_CollectionViewCell.self)
        
        collectionView.backgroundColor = .systemYellow
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        self.collectionView = collectionView
    }
        
    lazy var layoutForSection: UICollectionViewCompositionalLayoutSectionProvider = { section, _ -> NSCollectionLayoutSection? in
        let sectionType = self.sections[section].type
        
        switch sectionType {
            case .banners:
                break
            case .tendingPosts:
                break
            case .users:
                break
            case .trendingHashtags:
                break
            case .recommended:
                break
            case .popular:
                break
            case .new:
                break
        }
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(1)
            )
        )
        item.contentInsets = NSDirectionalEdgeInsets.init(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        // Group
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.90),
                heightDimension: .absolute(150)),
            subitems: [item])
        
        // Section Layout
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.orthogonalScrollingBehavior = .groupPaging
       
        // Return
        return sectionLayout
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
        let cell: Dummy_CollectionViewCell = collectionView.dequeueReusableCell(for: indexPath)
        
        cell.backgroundColor = randomColor()
        return cell
    }
    
    
}

extension ExploreViewController: UISearchBarDelegate {
    
}

class Dummy_CollectionViewCell: UICollectionViewCell, Reusable {
    
}
