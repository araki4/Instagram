//
//  CommentData.swift
//  Instagram
//
//  Created by ryouta.araki4 on 2022/02/18.
//

import UIKit
import Firebase

class CommentData: NSObject {
    var uid: String?
    var comment: String?
    var date: Date?
    
    init(document: QueryDocumentSnapshot) {
        
        let postDic = document.data()
        
        self.uid = postDic["uid"] as? String
        
        self.comment = postDic["uid"] as? String
        
        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
    }
}
