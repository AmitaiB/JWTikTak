//
//  CaptionViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 3/15/22.
//

import UIKit
import SCLAlertView
import ProgressHUD

class CaptionViewController: UIViewController {
    let videoURL: URL
    
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
    }

    private func postVideo() {
        // TODO: post video here!
        // Generate a unique video name based on id
        let newVideoName = StorageManager.shared.generateVideoName()
        
        ProgressHUD.show(L10n.postingMessage)
        
        // upload video
        StorageManager.shared.uploadVideoURL(from: videoURL, fileName: newVideoName) {
            ProgressHUD.dismiss()
            switch $0 {
                case .success(_):
                    // update db
                    DatabaseManager.shared.insertPost(filename: newVideoName) { [weak self] result in
                        switch result {
                            case .success(_):
                                self?.handlePostInsertionSuccess()
                            case .failure(let error):
                                self?.handleOpError(error)
                        }
                    }
                case .failure(let error):
                    self.handleOpError(error)
            }
        }
    }
    
    private func handlePostInsertionSuccess() {
        // reset camera, and switch to feed
        HapticsManager.shared.vibrate(for: .success)
        navigationController?.popToRootViewController(animated: true)
        tabBarController?.selectedIndex = 0
        tabBarController?.tabBar.isHidden = false
        SCLAlertView().showSuccess(L10n.success)
    }
    
    private func handleOpError(_ error: Error) {
        HapticsManager.shared.vibrate(for: .error)
        // alert
        SCLAlertView().showError(L10n.error, subTitle: error.localizedDescription)
    }
}
