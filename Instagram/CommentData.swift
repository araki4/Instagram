//
//  CommentData.swift
//  Instagram
//
//  Created by ryouta.araki4 on 2022/02/18.
//

import UIKit
import Firebase

class CommentData: NSObject {
    var id: String
    var uid: String?
    var userName: String?
    var comment: String?
    var date: Date?
    
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID
        
        let postDic = document.data()
        
        self.uid = postDic["uid"] as? String
        
        self.userName = postDic["userName"] as? String
        
        self.comment = postDic["comment"] as? String
        
        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
    }
}
