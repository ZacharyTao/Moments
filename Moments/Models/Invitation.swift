//
//  Invitation.swift
//  MomentsV2
//
//  Created by Zachary Tao on 4/10/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Invitation: Codable, Identifiable, Equatable{
    //this id is the reciever's id
    @DocumentID var id: String?
    var senderProfilePictureURL: URL?
    var senderName: String?
    var senderId: String?
    
    var recieverName: String?
    var recieverId: String?
}
