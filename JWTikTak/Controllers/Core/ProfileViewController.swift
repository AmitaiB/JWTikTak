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
    /// The `User` being profiled.
    ///
    /// - warning: Not necessarily the `currentUser`
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
                    self.configure(with: user)
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
        title = user.displayString
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
                    self?.navigationController?.pushViewController(settingsVC, animated: true)
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
        
        let headerViewModel = ProfileHeaderViewModel(
            avatarImageURL: self.user.profilePictureURL,
            followerCount:  self.user.followers?.count,
            followingCount: self.user.following?.count,
            profileStyle:   self.getProfileStyle()
        )
        header.configure(with: headerViewModel)
        
        return header
    }
    
    // TODO: Guarantee that this waits for completion (move to await/async?)
    func getProfileStyle() -> ProfileHeaderViewModel.Style {
        guard !isProfileOfLoggedInUser
        else { return .isLoggedInUser }

        let group = DispatchGroup()
        group.enter()
        DatabaseManager.shared.isValidRelationship(for: user, type: .followers) { [weak self] result in
            defer { group.leave() }
            
            switch result {
                case .failure(let error): print(error.localizedDescription)
                case .success(let isFollower):
                    self?.isFollower = isFollower
            }
        }

        group.notify(queue: .main) {
            print(#function, " INSIDE the notification, \(#line)")
        }
        
        print(#function, " OUTSIDE the notification, \(#line)")
        return isFollower ?
            .isFollowing : .isNotFollowing
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
            // Edit profile
            // TODO: Build out Edit Profile View Controller
            let editVC = EditProfileViewController()
            let editNav = UINavigationController(rootViewController: editVC)
            present(editNav, animated: true)
        } else {
            toggleFollow()
        }
    }
    
    private func toggleFollow() {
        guard let currentUserUid = DatabaseManager.shared.currentUser?.identifier
        else { return }
        
        // TODO: Replace `{_ in}` with a real completion.
        if isFollower {
            // Unfollow
            // Remove in the current user's followING
            DatabaseManager.shared.updateCurrentUserListOfFollowIDs(
                removing: [user.identifier],
                ofType: .followers,
                completion: {_ in}
            )
            isFollower = false
            
            // Remove in the target user's followERS
            DatabaseManager.shared.updateListOfFollowIDs(
                for: user,
                removing: [currentUserUid],
                ofType: .followers,
                completion: {_ in}
            )
            
            // TODO: change style
        } else {
            // Follow
            
            // Insert in the current user's followING
            DatabaseManager.shared.updateCurrentUserListOfFollowIDs(
                adding: [user.identifier],
                ofType: .followers,
                completion: {_ in}
            )
            isFollower = true
            
            // Insert in the target user's followERS
            DatabaseManager.shared.updateListOfFollowIDs(
                for: user,
                inserting: [currentUserUid],
                ofType: .followers,
                completion: {_ in}
            )

            // TODO: change this ProfileVC's style (and refresh the UI)
        }
    }
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView,
                                             didTapFollowersButtonWith viewModel: ViewModel) {
        let vc = UserListViewController(type: .followers, user: user)
        navigationController?.pushViewController(vc, animated: true)
        print(#function)
    }
    
    func profileHeaderCollectionReusableView(_ header: ProfileHeaderCollectionReusableView,
                                             didTapFollowingButtonWith viewModel: ViewModel) {
        let vc = UserListViewController(type: .following, user: user)
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
        DatabaseManager.shared.updateUserValues(newProfilePicURL: url, shouldSyncWithServer: true)
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
