//
//  CaptionViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 3/15/22.
//

import UIKit
import SCLAlertView
import ProgressHUD
import SnapKit

class CaptionViewController: UIViewController {
    let videoURL: URL
    
    private let captionTextView: UITextView = {
        let textView = UITextView()
        textView.contentInset        = [\.all: 5]
        textView.placeholder         = "Testing out placeholders!"
        textView.backgroundColor     = .secondarySystemBackground
        textView.layer.cornerRadius  = 8
        textView.layer.masksToBounds = true
        return textView
    }()
    
    init(videoURL: URL) {
        self.videoURL = videoURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Caption"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: L10n.post,
            style: .done,
            action: { [weak self] in self?.postVideo() }
        )
        view.addSubview(captionTextView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        captionTextView.snp.makeConstraints { make in
            make.width.equalToSuperview().offset(-10)
            make.height.equalTo(150)
            make.top.left.equalToSuperview().offset(10)
        }
        captionTextView.becomeFirstResponder()
    }

    /*
     Needs to:
     1. Upload the actual video to FIR storage
     2. Update the RTDb:
      a. Add owner (a post) to the Posts.
      b. Add a ref to that Post in the owning User.
     */
    private func postVideo() {
        captionTextView.resignFirstResponder()
        
        // Generate a unique video name based on timestamp
        let newVideoIdentifier = StorageManager.generateVideoIdentifier()
        
        ProgressHUD.show(L10n.postingMessage)
        
        // upload video
        StorageManager.shared.uploadVideo(withLocalURL: videoURL, filename: newVideoIdentifier) {
            ProgressHUD.dismiss()
            switch $0 {
                case .success(_):
                    self.handlePostUploadToStorageSuccess(withFilename: newVideoIdentifier)
                    HapticsManager.shared.vibrate(for: .success)
                case .failure(let error):
                    HapticsManager.shared.vibrate(for: .error)
                    self.handleOpError(error)
            }
        }
    }
    
    private func handlePostUploadToStorageSuccess(withFilename filename: String) {
        HapticsManager.shared.vibrate(for: .success)
        let caption = captionTextView.text ?? ""
        
        guard let currentUser = DatabaseManager.shared.currentUser else {
            print(DatabaseError.cachedUserUidNil)
            return
        }
        
        let newPost = PostModel(userUid: currentUser.identifier, filename: filename, caption: caption)
        DatabaseManager.shared.insert(newPost: newPost) { [weak self] result in
            switch result {
                case .success(_):
                    self?.handlePostInsertionSuccess(newPost)
                case .failure(let error):
                    self?.handleOpError(error)
            }
        }
    }
    
    private func handlePostInsertionSuccess(_ newPost: PostModel? = nil) {
        HapticsManager.shared.vibrate(for: .success)
        
        // UI response
        SCLAlertView().showSuccess(L10n.success)
        HapticsManager.shared.vibrate(for: .success)
        // TODO: use UserInfo properly, instead of abusing `object`
        NotificationCenter.default.post(name: .didAddNewPost, object: newPost)

        // TODO: reset camera
        // switch to feed
        navigationController?.popToRootViewController(animated: true)
        tabBarController?.selectedIndex   = 0
        tabBarController?.tabBar.isHidden = false
    }
    
    private func handleOpError(_ error: Error) {
        HapticsManager.shared.vibrate(for: .error)
        // alert
        SCLAlertView().showError(L10n.error, subTitle: error.localizedDescription)
    }
}
