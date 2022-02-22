//
//  PostViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import SnapKit
import RandomColor
import Actions
import JWPlayerKit

protocol PostViewControllerDelegate: AnyObject {
    func postViewController(_ viewController: PostViewController, didLike post: PostModel)
    func postViewController(_ viewController: PostViewController, didSelectProfileFor post: PostModel)
}

class PostViewController: UIViewController {
    var model: PostModel
    weak var delegate: PostViewControllerDelegate?
    
    // MARK: UI Objects
    private lazy var likeButton: UIButton = {
        createUserReactionButton(withSymbol: L10n.SFSymbol.heartFill)
    }()
    
    private lazy var commentButton: UIButton = {
        createUserReactionButton(withSymbol: L10n.SFSymbol.textBubbleFill)
    }()
    
    private lazy var shareButton: UIButton = {
        createUserReactionButton(withSymbol: L10n.SFSymbol.squareAndArrowUp)
    }()
    
    private lazy var profileButton: UIButton = {
        createUserReactionButton(withSymbol: L10n.SFSymbol.photoCircle, asAvatar: true)
    }()

    
    /// This is a placeholder for a more interactive UITextView in a real app.
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.text            = "Check out this video! #fyp #foryou #foryoupage"
        label.textAlignment   = .left
        label.textColor       = .white
        label.backgroundColor = .systemGray
        label.font            = .systemFont(ofSize: 18)
        label.numberOfLines   = 0
        return label
    }()
    
    var player: JWPlayer?
    
    // MARK: - Lifecycle
    init(model: PostModel, delegate: PostViewControllerDelegate? = nil) {
        self.model    = model
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = randomColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMockVideo()
        setupButtons()
        setupDoubleTapToLike()
        
        // Captions label placeholder
        view.addSubview(captionLabel)
//        captionLabel.sizeToFit()
        captionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(self.buttonsRow.snp.leftMargin).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(-100)
        }
    }
    
    private func configureMockVideo() {
        guard let path = Bundle.main.path(forResource: L10n.Mock.testVideo, ofType: L10n.mp4)
        else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            let playlistItem = try JWPlayerItemBuilder()
                .file(url)
                .build()
                    
            let config = try JWPlayerConfigBuilder()
                // doubles playlistItem b/c of SDK-9317 bug.
                .playlist([playlistItem, playlistItem])
                .autostart(true)
                .repeatContent(true)
                .build()
            
            let playerView = JWPlayerView()
            playerView.player.configurePlayer(with: config)
            view = playerView
            playerView.player.delegate = playerMockDelegateObject
            playerView.player.playbackStateDelegate = playerMockDelegateObject
        }
        catch { print(error.localizedDescription)}
    }
    
    let playerMockDelegateObject = DefaultJWPlayerXDelegate()
    
    // TODO: Once this loads a PostModel for real, split off the Profile button creation.
    private func createUserReactionButton(withSymbol symbolName: String, asAvatar: Bool = false) -> UIButton {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: symbolName), for: .normal)
        button.tintColor = .white
        button.clipsToBounds = true
        button.snp.makeConstraints { $0.width.height.equalTo(40)}
        if asAvatar  {
            button.layer.cornerRadius       = 20
            button.imageView?.clipsToBounds = true
        }
        return button
    }
    
    private func setupButtons() {
        likeButton.add(event: .touchUpInside) { [self] _ in
            self.toggleLike()
            delegate?.postViewController(self, didLike: model)
        }
        
        commentButton.add(event: .touchUpInside) { [self] _ in
            // Present comment tray
            let commentsVC = CommentsViewController(post: model)
            present(commentsVC, animated: true, completion: nil)
        }

        shareButton.add(event: .touchUpInside) { [self] _ in
            guard let mockTikTokURL = URL(string: "https://www.tiktok.com") else { return }
            
            let shareSheet = UIActivityViewController(
                activityItems: [mockTikTokURL],
                applicationActivities: [])
            present(shareSheet, animated: true)
        }
        
        profileButton.add(event: .touchUpInside) { [self] control in
            guard let button = control as? UIButton else { return }
            button.setBackgroundImage(Asset.test.image, for: .normal)
            delegate?.postViewController(self, didSelectProfileFor: model)
        }
        
        setupButtonsRow(with: profileButton, likeButton, commentButton, shareButton)
    }
    
    private var buttonsRow: UIStackView!
    // Put the user-reaction buttons in a vertical stack view on the right.
    private func setupButtonsRow(with buttons: UIButton...) {
        buttonsRow = UIStackView(arrangedSubviews: buttons)
        view.addSubview(buttonsRow)
        
        buttonsRow.axis         = .vertical
        buttonsRow.spacing      = 15
        buttonsRow.alignment    = .center
        buttonsRow.distribution = .fillEqually
        buttonsRow.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-150)
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    /// A separate function accessible to both the 'Like' button and 2x tapping.
    private func toggleLike() {
        model.isLikedByCurrentUser.toggle()
        
        UIView.animate(withDuration: 0.2, delay: 0, options: []) {
            self.likeButton.tintColor = self.model.isLikedByCurrentUser ? .systemRed : .white
        }
    }
    
    private func setupDoubleTapToLike() {
        let tap = UITapGestureRecognizer { [self] gesture in
            // 2xTap in TikTok is 'one-way' for liking, not unliking.
            if !model.isLikedByCurrentUser { toggleLike() }
            
            // Heart animation
            animateHeart(at: gesture.location(in: view))
        }

        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
    
    private func animateHeart(at touchPoint: CGPoint) {
        // Setup pre-animation state
        let imageView = UIImageView(image: UIImage(systemName: L10n.SFSymbol.heartFill))
        imageView.tintColor   = .systemRed
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(origin: touchPoint, size: CGSize(width: 100, height: 100))
        imageView.transform = imageView.transform.rotated(by: .pi / -CGFloat.random(in: 4...8))
        imageView.alpha = 0 // start hidden
        view.addSubview(imageView)

        imageView.fadeIn(withDuration: 0.2,
                         delay: 0.2,
                         completion: { _ in imageView.fadeOut() })
    }
}

