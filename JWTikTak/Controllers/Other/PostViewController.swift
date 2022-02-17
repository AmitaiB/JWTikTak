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

class PostViewController: UITabBarController {
    var model: PostModel

    // MARK: UI Objects
    private lazy var likeButton: UIButton = {
       createButton(withSymbol: L10n.SFSymbol.likeFill)
    }()
    
    private lazy var commentButton: UIButton = {
        createButton(withSymbol: L10n.SFSymbol.commentFill)
    }()
    
    private lazy var shareButton: UIButton = {
        createButton(withSymbol: L10n.SFSymbol.share)
    }()
    
    /// This is a placeholder for a more interactive UITextView in a real app.
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = "Check out this video! #fyp #foryou #foryoupage"
        label.backgroundColor = .systemGray
        label.textColor = .white
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    // MARK: - Lifecycle
    init(model: PostModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        view.backgroundColor = randomColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtons()
        setupDoubleTapToLike()
        view.addSubview(captionLabel)
        captionLabel.sizeToFit()
        captionLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(self.buttonsRow.snp.leftMargin).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottomMargin).offset(-100)
        }
    }
    
    
    private func createButton(withSymbol symbolName: String) -> UIButton {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: symbolName), for: .normal)
        button.tintColor = .white
        button.snp.makeConstraints { $0.width.height.equalTo(40)}
        return button
    }
    
    
    private func setupButtons() {
        likeButton.add(event: .touchUpInside) { [self] _ in
            self.toggleLike()
        }
        
        commentButton.add(event: .touchUpInside) { _ in
            print("present comment tray")
        }

        shareButton.add(event: .touchUpInside) { [self] _ in
            guard let mockTikTokURL = URL(string: "https://www.tiktok.com") else { return }
            
            let shareSheet = UIActivityViewController(
                activityItems: [mockTikTokURL],
                applicationActivities: [])
            present(shareSheet, animated: true)
        }
        
        setupButtonsRow(with: likeButton, commentButton, shareButton)
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
        let imageView = UIImageView(image: UIImage(systemName: L10n.SFSymbol.likeFill))
        imageView.tintColor   = .systemRed
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(origin: touchPoint, size: CGSize(width: 100, height: 100))
        imageView.alpha = 0
        view.addSubview(imageView)
        
        
        imageView.transform = imageView.transform.rotated(by: .pi / -CGFloat.random(in: 4...8))
        
        imageView.fadeIn(withDuration: 0.2,
                         delay: 0.2,
                         completion: { _ in imageView.fadeOut() })
    }
}
