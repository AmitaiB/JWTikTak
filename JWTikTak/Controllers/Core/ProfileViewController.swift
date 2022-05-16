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

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let cView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cView.backgroundColor = .systemBackground
        cView.showsVerticalScrollIndicator = false
        cView.register(cellType: PlaceholderCollectionViewCell.self)
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
        
        let width = (view.width - 2 * layout.minimumInteritemSpacing) / 3
        let height = (view.height - 2 * layout.minimumLineSpacing) / 4
        return CGSize(width: width, height: height)
    }
}
