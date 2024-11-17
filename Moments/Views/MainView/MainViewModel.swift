//
//  MainViewModel.swift
//  MomentsV2
//
//  Created by Zachary Tao on 4/14/24.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseAuth
import FirebaseMessaging
import SwiftUI


@MainActor
class MainViewModel: ObservableObject{
    
    struct ConnectionPreview: Hashable, Codable{
        var connectionID: String
        var recieverName: String
        var recieverProfilePhoto: URL?
        var lastPhotoURL: URL?
        var lastCaption: String?
        var timeStamp: Date?
        
        var lastPhotoSenderName: String?
        var lastPhotoSenderProfilePic: URL?
    }
    
    init(){
        fetchConnectionPreviews()
    }
    
    private var db = Firestore.firestore()
    @Published var connectionPreviews: [ConnectionPreview] = []
    @Published var isLoading = false
    @Published var errorMessage = ""
    
    func fetchConnectionPreviews(){
        guard let userID = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        connectionPreviews = []
        
        Task{
            do{
                let documents = try await db.collection("Connections")
                    .whereField("participantsId", arrayContains: userID)
                    .getDocuments()
                
                for document in documents.documents{
                    
                    let connection = try document.data(as: Connection.self)
                    var recieverID = ""
                    for id in connection.participantsId{
                        if id != userID{
                            recieverID = id
                        }
                    }
                    guard let connectionID = connection.id else{
                        print("error getting connection id")
                        return
                    }
                    
                    let documents = try await db.collection("Connections").document(connectionID).collection("messages")
                        .order(by: "timestamp", descending: true)
                        .limit(to: 1)
                        .getDocuments()
                    let latestMessage = try documents.documents.first?.data(as: Message.self)
                    let reciever = try await db.collection("Users").whereField("userId", isEqualTo: recieverID).limit(to: 1).getDocuments().documents.first?.data(as: MomentsUser.self)
                    let currentUser = try await db.collection("Users").whereField("userId", isEqualTo: userID).limit(to: 1).getDocuments().documents.first?.data(as: MomentsUser.self)
                    if let reciever{
                        
                        if latestMessage?.senderId == reciever.id{
                            withAnimation {
                                self.connectionPreviews.append(ConnectionPreview(connectionID: connectionID, recieverName: reciever.userName, recieverProfilePhoto: reciever.profilePictureURL, lastPhotoURL: latestMessage?.photoURL, lastCaption: latestMessage?.caption ?? "", timeStamp: latestMessage?.timestamp, lastPhotoSenderName: reciever.userName, lastPhotoSenderProfilePic: reciever.profilePictureURL))
                            }
                        }else{
                            withAnimation {
                                self.connectionPreviews.append(ConnectionPreview(connectionID: connectionID, recieverName: reciever.userName, recieverProfilePhoto: reciever.profilePictureURL, lastPhotoURL: latestMessage?.photoURL, lastCaption: latestMessage?.caption ?? "", timeStamp: latestMessage?.timestamp, lastPhotoSenderName: currentUser?.userName, lastPhotoSenderProfilePic: currentUser?.profilePictureURL))
                            }
                        }
                    }
                }
                isLoading = false
            }catch{
                print("error getting connection data : \(error.localizedDescription)")
                isLoading = false
            }
            
        }
        
    }
}






