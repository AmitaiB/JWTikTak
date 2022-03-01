//
//  ExploreSectionLayoutProvider.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/21/22.
//

import UIKit

/// Encapsulates the logic for the details of each section's layout.
class ExploreSectionLayoutProvider {
    static var bannerSectionLayout: NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        // Group
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(0.90),
                heightDimension: .absolute(200)),
            subitems: [item])
        
        // Section Layout
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.orthogonalScrollingBehavior = .groupPaging
        
        // Return
        return sectionLayout
    }
    
    static var postsSectionLayout: NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        // Group
        let verticalGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(100),
                heightDimension: .absolute(240)
            ),
            subitem: item,
            count: 2
        )
        
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(105),
                heightDimension: .absolute(240)),
            subitems: [verticalGroup])
        
        // Section Layout
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.orthogonalScrollingBehavior = .continuous
        
        // Return
        return sectionLayout
    }
    
    static var popularPostsSectionLayout: NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        // Group
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(105),
                heightDimension: .absolute(200)),
            subitems: [item])
        
        // Section Layout
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.orthogonalScrollingBehavior = .continuous
        
        // Return
        return sectionLayout
    }
    
    static var usersSectionLayout: NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        // Group
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .absolute(200),
                heightDimension: .absolute(220)),
            subitems: [item])
        
        // Section Layout
        let sectionLayout = NSCollectionLayoutSection(group: group)
        sectionLayout.orthogonalScrollingBehavior = .groupPaging
        
        // Return
        return sectionLayout
    }
    
    static var trendingHashtagsSectionLayout: NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        item.contentInsets = .init(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        // Group
        let verticalGroup = NSCollectionLayoutGroup.vertical(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .absolute(60)
            ),
            subitems: [item]
        )
        
        // Section Layout
        let sectionLayout = NSCollectionLayoutSection(group: verticalGroup)
        sectionLayout.orthogonalScrollingBehavior = .groupPaging
        
        // Return
        return sectionLayout
    }
}
