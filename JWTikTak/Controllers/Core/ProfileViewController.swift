//
//  ProfileViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import Reusable

#warning("TODO")
class PlaceholderCollectionViewCell: UICollectionViewCell, Reusable {}

class ProfileViewController: UIViewController {
    let user: User
    var isProfileOfLoggedInUser: Bool {user == DatabaseManager.shared.currentUser}
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let cView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cView.backgroundColor = .systemBackground
        cView.showsVerticalScrollIndicator = false
        cView.register(cellType: PlaceholderCollectionViewCell.self)
        cView.register(supplementaryViewType: ProfileHeaderCollectionReusableView.self,
                       ofKind: .elementKindSectionHeader)
        return cView
    }()
    
    // MARK: Initialization
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("\(#file): Init not implemented")
    }
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.username.uppercased()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate   = self
        
        if isProfileOfLoggedInUser {
            navigationItem.rightBarButtonItem = .init(image: UIImage(
                systemName: L10n.SFSymbol.gear)) { [weak self] in
                    let settingsVC = SettingsViewController()
                    self?.present(settingsVC, animated: true)
                    // or
//                    self?.navigationController?.pushViewController(settingsVC, animated: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

// MARK: UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        30
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PlaceholderCollectionViewCell.self)
        cell.backgroundColor = .systemBlue
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == .elementKindSectionHeader
        else { return UICollectionReusableView() }
        
        let header: ProfileHeaderCollectionReusableView =
        collectionView.dequeueReusableSupplementaryView(
            ofKind: .elementKindSectionHeader,
            for: indexPath
        )
        
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: 300)
    }
}

// MARK: UICollectionViewDelegate
extension ProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        else { return .zero }
        
        let width  = (view.width  - 2 * layout.minimumInteritemSpacing) / 3
        let height = (view.height - 2 * layout.minimumLineSpacing) / 4
        return CGSize(width: width, height: height)
    }
}

// MARK: Helper
fileprivate extension String {
    /// A supplementary view that identifies the header for a given section.
    static var elementKindSectionHeader: String { UICollectionView.elementKindSectionHeader }
}
