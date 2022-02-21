//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by ryouta.araki4 on 2022/02/17.
//

import UIKit
import FirebaseStorageUI
import Firebase

class PostTableViewCell: UITableViewCell, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var commentTableHeightConstraint: NSLayoutConstraint!

    var commentArray: [CommentData] = []
    
    // Firestoreのリスナー
    var listener: ListenerRegistration?
    
    // セルの高さ
    let cellHeight: CGFloat = 30
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.commentTableView.delegate = self
        self.commentTableView.dataSource = self
        self.commentTableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommentCell")
        // self.commentTableView.isScrollEnabled = false
        self.commentTableView.layer.borderColor = UIColor.systemGray5.cgColor
        self.commentTableView.layer.borderWidth = 2.0
        self.commentTableView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // コンテンツの内容に応じて UITableView の高さを変える
        // let itemCount = self.commentArray.count
        // self.commentTableHeightConstraint.constant = CGFloat(itemCount) * self.cellHeight
        return self.commentArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        let comment = self.commentArray[indexPath.row]
        let commentText = comment.comment != nil ? comment.comment : ""
        let commentUserName = comment.userName != nil ? comment.userName : ""
        cell.textLabel?.text = commentText! + "(" + commentUserName! + ")"
        return cell
    }
    
    // Cell の高さ
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    // PostDataの内容をセルに表示
    func setPostData(_ postData: PostData) {
        // 画像の表示
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        postImageView.sd_setImage(with: imageRef)

        // キャプションの表示
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"

        // 日時の表示
        self.dateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
        }

        // いいね数の表示
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"

        // いいねボタンの表示
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        // コメントの表示
        // ログイン済みか確認
        if Auth.auth().currentUser != nil {
            // listenerを登録して投稿データの更新を監視する
            let commentsRef = Firestore.firestore().collection(Const.PostPath).document(postData.id).collection(Const.CommentPath).order(by: "date", descending: true)
            
            listener = commentsRef.addSnapshotListener() { (querySnapshot, error) in
                if let error = error {
                    print("DEBUG_PRINT: (comments)snapshotの取得が失敗しました。 \(error)")
                    return
                }
                // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                self.commentArray = querySnapshot!.documents.map{ document in
                    print("DEBUG_PRINT: (comments)document取得 \(document)")
                    let commentData = CommentData(document: document)
                    return commentData
                }
                self.commentTableView.reloadData()
            }
        }
    }
}
