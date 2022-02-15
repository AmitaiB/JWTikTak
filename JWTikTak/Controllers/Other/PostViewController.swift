//
//  PostViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/10/22.
//

import UIKit
import SnapKit
import RandomColor

class PostViewController: UITabBarController {
    let model: PostModel

    private lazy var likeButton: UIButton = {
       createButton(withSymbol: L10n.SFSymbol.likeFill)
    }()
    
    private lazy var commentButton: UIButton = {
        createButton(withSymbol: L10n.SFSymbol.commentFill)
    }()
    
    private lazy var shareButton: UIButton = {
        createButton(withSymbol: L10n.SFSymbol.share)
    }()

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

        let reactionButtons = [likeButton, commentButton, shareButton]
        reactionButtons.forEach {
            $0.snp.makeConstraints { $0.width.height.equalTo(40)}
        }
        
        let buttonsRow = UIStackView(arrangedSubviews: reactionButtons)
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
    
    private func createButton(withSymbol symbolName: String) -> UIButton {
        let button = UIButton()
        button.setBackgroundImage(UIImage(systemName: symbolName), for: .normal)
        button.tintColor = .white
        return button
    }
}
