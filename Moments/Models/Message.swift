//
//  Models.swift
//  MomentsV2
//
//  Created by Zachary Tao on 3/23/24.
//

import Foundation
import FirebaseFirestore
struct Message: Identifiable, Codable, Hashable{
    @DocumentID var id : String?
    let senderId: String

    var photoURL: URL?
    var caption: String?
    var timestamp: Date?
    var location: String?
}

struct MessageComment: Identifiable, Codable{
    @DocumentID var id: String?
    var messageId: String?
    let senderId: String?
    let recieverId: String?
    
    let comment: String
    var timestamp: Date
}
