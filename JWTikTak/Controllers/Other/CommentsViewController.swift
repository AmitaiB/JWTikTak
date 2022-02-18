//
//  CommentViewController.swift
//  JWTikTak
//
//  Created by Amitai Blickstein on 2/16/22.
//

import UIKit
import SnapKit
import Reusable

class CommentsViewController: UIViewController {
    private let post: PostModel
    private var comments = [PostComment]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(cellType: CommentTableViewCell.self)
        return tableView
    }()
    
    // MARK: - Lifecycle
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
        view.layer.cornerRadius = 5

        fetchPostComments()
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(40)
        }
        tableView.backgroundColor = .systemGreen
    }
    
    private func fetchPostComments() {
        comments = PostComment.mockComments()
    }
}

// MARK: - UITableViewDataSource
extension CommentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = comments[indexPath.row]
        let cell = tableView.dequeueReusableCell(for: indexPath) as CommentTableViewCell
        cell.configure(with: comment)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - UITableViewDelegate
extension CommentsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
