//
//  Chatroom.swift
//  MomentsV2
//
//  Created by Zachary Tao on 4/11/24.
//

import Foundation
import FirebaseFirestore

struct Connection: Identifiable, Codable, Hashable{
    static func == (lhs: Connection, rhs: Connection) -> Bool {
        if let id1 = lhs.id, let id2 = rhs.id{
            return id1 == id2
        }
        return false
    }
    func hash(into hasher: inout Hasher) {
           hasher.combine(id)
       }
    
    @DocumentID var id: String?
    

    var participantsId: [String] = []
    var messages: [Message] = []
}
