//
//  ProfileViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import PhotosUI
import Reusable
import SCLAlertView
import ProgressHUD
import Actions

class ProfileViewController: UIViewController {
    private(set)var user: User
    private(set)var posts = [PostModel]()
    var isProfileOfLoggedInUser: Bool {user == DatabaseManager.shared.currentUser}
    
    // Users following/followers by UID.
    private var followers = [String]()
    private var following = [String]()
    private var isFollower = false

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical

        let cView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cView.backgroundColor = .systemBackground
        cView.showsVerticalScrollIndicator = false
        cView.register(cellType: PostCollectionViewCell.self)
        cView.register(supplementaryViewType: ProfileHeaderCollectionReusableView.self,
                       ofKind: .elementKindSectionHeader)
        return cView
    }()
    
    
    // MARK: - Initialization
    
    init(userId: String) {
        user = .empty
        super.init(nibName: nil, bundle: nil)

        // TODO: Cache User objects in a [User UID: User] structure.
        DatabaseManager.shared.getUser(withId: userId) { result in
            switch result {
                case .success(let user):
                    self.user = user
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    func configure(with user: UserModel) {
        self.user = user
        collectionView.reloadData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("\(#file): Init not implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = user.username?.uppercased()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate   = self
        cameraPicker.delegate     = self
        imagePicker.delegate      = self
        
        #if DEBUG
        navigationItem.leftBarButtonItem = .init(image: UIImage(
            systemName: L10n.SFSymbol.gear)
        ) { [weak self] in
            self?.collectionView.reloadData()
        }
        navigationItem.leftBarButtonItem?.tintColor = .systemRed
        #endif
        
        if isProfileOfLoggedInUser {
            navigationItem.rightBarButtonItem = .init(image: UIImage(
                systemName: L10n.SFSymbol.gear)) { [weak self] in
                    let settingsVC = SettingsViewController()
                    self?.present(settingsVC, animated: true)
                    // or
//                    self?.navigationController?.pushViewController(settingsVC, animated: true)
            }
        }
        
        // FIXME: Uploads once, but collectionView updates with two copies of new posts.
        // reloadData, or reloadItems? Where else is reloadX called? fetch?
        NotificationCenter.default.add(observer: self, name: .didAddNewPost) { [weak self] notification in
            
            guard
                let newPost = notification.object as? PostModel
            else { return }

            self?.posts += [newPost]
            guard let newPostsCount = self?.posts.count
            else { return }
            let newPostPath = IndexPath(item: newPostsCount - 1, section: 0)
            DispatchQueue.main.async {
                self?.collectionView.reloadItems(at: [newPostPath])
            }
        }
        
        fetchPosts()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    let cameraPicker: UIImagePickerController = {
        let cameraPicker = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            cameraPicker.sourceType    = .camera
            cameraPicker.cameraDevice  = .front
            cameraPicker.allowsEditing = true
        }
        return cameraPicker
    }()
    
    let imagePicker: PHPickerViewController = {
        var config = PHPickerConfiguration()
        config.filter = .images
        return PHPickerViewController(configuration: config)
    }()
    
    func fetchPosts() {
        DatabaseManager.shared.getPosts(for: user) { [weak self] result in
            switch result {
                case .success(let posts):
                    DispatchQueue.main.async {
                        self?.posts = posts
                        self?.collectionView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension ProfileViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { 1 }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let postModel = posts[indexPath.row]
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PostCollectionViewCell.self)
        cell.configure(with: postModel)
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
        
        header.delegate = self
        
        // Dispatch Group to collect the info required for the viewModel
        let group = DispatchGroup()
        group.enter()
        group.enter()
        
        DatabaseManager.shared.getRelationships(for: user, ofType: .following) { [weak self] following in
            self?.following = following
            group.leave()
        }
        
        DatabaseManager.shared.getRelationships(for: user, ofType: .followers) { [weak self] followers in
            self?.followers = followers
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self
            else { return }
            let headerViewModel = ProfileHeaderViewModel(avatarImageURL: self.user.profilePictureURL,
                                                         followerCount: self.followers.count,
                                                         followingCount: self.following.count,
                                                         profileStyle: self.getProfileStyle())
            header.configure(with: headerViewModel)
        }
        
        return header
    }
    
    // TODO: Account for .isFollowing Status
    func getProfileStyle() -> ProfileHeaderViewModel.Style {
        if isProfileOfLoggedInUser {
            return .isLoggedInUser // good
        } else {
            return .isNotFollowing // needs TODO
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.width, height: 300)
    }
}

// MARK: UICollectionViewDelegate
extension ProfileViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        // open post
        let post = posts[indexPath.row]
        let postVC = PostViewController(model: post)
        postVC.title = "Video" // ??
        postVC.delegate = self
        present(postVC, animated: true)
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

extension ProfileViewController: ProfileHeaderCollectionReusableViewDelegate {
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView,
                                             didTapPrimaryButtonWith viewModel: ViewModel) {
        print(#function)
        if isProfileOfLoggedInUser {
            // edit profile
        } else {
            // loggedInUser should follow/unfollow this VC's self.user
        }
    }
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView,
                                             didTapFollowersButtonWith viewModel: ViewModel) {
        let vc = UserListViewController(type: .followers, user: user)
        vc.userIds = followers
        navigationController?.pushViewController(vc, animated: true)
        print(#function)
    }
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView,
                                             didTapFollowingButtonWith viewModel: ViewModel) {
        let vc = UserListViewController(type: .following, user: user)
        vc.userIds = following
        navigationController?.pushViewController(vc, animated: true)
        print(#function)
    }
    
    enum PicturePickerType {
        case camera
        case photosLibrary
    }
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView, didTapAvatarImageWith viewModel: ViewModel) {
        print(#function)
        // Only logged in user can change their profile picture.
        guard isProfileOfLoggedInUser else { return }
            
        // create alert
        let alertView = SCLAlertView(appearance: .defaultCloseButtonIsHidden)
        alertView.addButton(L10n.camera) {
            self.presentProfilePicturePicker(with: .camera)
        }
        alertView.addButton(L10n.photosLibrary) {
            self.presentProfilePicturePicker(with: .photosLibrary)
        }
        alertView.addButton(L10n.cancel) {}
        
        alertView.showEdit(L10n.profilePicture, animationStyle: .noAnimation)
    }
        
    private func presentProfilePicturePicker(with type: PicturePickerType) {
        switch type {
            case .camera:
                presentCameraPicker()
            case .photosLibrary:
                presentPhotosLibraryPicker()
        }
    }
    
    private func presentCameraPicker() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            present(cameraPicker, animated: true)
        }
    }
    
    private func presentPhotosLibraryPicker() {
        present(imagePicker, animated: true)
    }
    
    private func uploadSelectedProfilePicture(_ image: UIImage) {
        StorageManager.shared.uploadProfilePicture(with: image) { [weak self] result in
            switch result {
                case .success(let downloadUrl):
                    ProgressHUD.showSuccess("Updated!")
                    // update the User object with the url
                    // reload the collectionview
                    self?.handleNewPicUrl(downloadUrl)
                case .failure(let error):
                    ProgressHUD.showError("Failed to upload profile picture: \(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    private func handleNewPicUrl(_ url: URL) {
        DatabaseManager.shared.updateCachedUserValues(newProfilePicURL: url, shouldSync: true)
        collectionView.reloadData()
    }
}

// MARK: PHPickerViewControllerDelegate
extension ProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        guard
            let itemProvider = results.first?.itemProvider,
            itemProvider.canLoadObject(ofClass: UIImage.self)
        else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
            error.ifSome { print($0.localizedDescription) }
                        
            guard let image = image as? UIImage else { return }
            self?.uploadSelectedProfilePicture(image)
        }
        dismiss(animated: true)
    }
}


// MARK: UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.editedImage] as? UIImage
        else { return }
        
        // upload image, update UI
        ProgressHUD.show("Uploading")
        self.uploadSelectedProfilePicture(image)
        dismiss(animated: true)
    }
}


// MARK: - PostViewControllerDelegate
// TODO: Implement delegate methods...
extension ProfileViewController: PostViewControllerDelegate {
    func postViewController(_ viewController: PostViewController, didLike post: PostModel) {
        print(" ** \(#function) NOT IMPLEMENTED")
    }
    
    func postViewController(_ viewController: PostViewController, didSelectProfileFor post: PostModel) {
        print(" ** \(#function) NOT IMPLEMENTED")
    }
}

// MARK: - Helper
fileprivate extension String {
    /// A supplementary view that identifies the header for a given section.
    static var elementKindSectionHeader: String { UICollectionView.elementKindSectionHeader }
}
