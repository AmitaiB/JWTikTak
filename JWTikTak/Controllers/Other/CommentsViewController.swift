//
//  CommentViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/16/22.
//

import UIKit

class CommentsViewController: UIViewController {
    private let post: PostModel
    
    init(post: PostModel) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        fetchPostComments()
        
        view.layer.cornerRadius = 5
    }
    
    private func fetchPostComments() {
        
    }
}
