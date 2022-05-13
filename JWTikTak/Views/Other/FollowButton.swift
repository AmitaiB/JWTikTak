//
//  RecordButton.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 3/9/22.
//

import UIKit

// TODO: Accept a view model?

/// A UIButton subclass with some UI presets, and has a following/notFollowing state.
class FollowButton: UIButton {
    // MARK: Button's state
    enum State {
        case isFollowing
        case isNotFollowing
    }
    
    private(set) var buttonState: State = .isNotFollowing { didSet { updateUI(for: buttonState) }
    }
    
    public func toggleState() {
        buttonState = (buttonState == .isFollowing) ?
            .isNotFollowing : .isFollowing
    }
    
    public func resetButtonStateForReuse() {
        updateUI(for: .isNotFollowing)
    }
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        stateAgnosticSetup()
        updateUI(for: buttonState)
    }
    
    private func stateAgnosticSetup() {
        layer.cornerRadius  = 6
        layer.masksToBounds = true
        layer.borderWidth   = 1
        titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    private func updateUI(for state: State) {
        switch state {
            case .isFollowing:
                setTitle(L10n.following.padded, for: .normal)
                setTitleColor(.darkText, for: .normal)
                backgroundColor   = .clear
                layer.borderColor = UIColor.lightGray.cgColor
            case .isNotFollowing:
                setTitle(L10n.follow.padded, for: .normal)
                setTitleColor(.white, for: .normal)
                backgroundColor   = .systemBlue
                layer.borderColor = nil
        }
    }
}

// TODO: Just use margins instead
fileprivate extension String {
    var padded: String { " " + self + " " }
}
