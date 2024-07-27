//
//  User.swift
//  MomentsV2
//
//  Created by Zachary Tao on 3/23/24.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

struct MomentsUser: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String?

    var userName: String
    var profilePictureURL: URL?
    
    var uniqueID: String = ShortCodeGenerator.getCode(length: 6)
    
    var FCMtoken: String?
}


