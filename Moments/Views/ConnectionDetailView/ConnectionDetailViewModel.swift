//
//  ConnectionDetailViewModel.swift
//  MomentsV2
//
//  Created by Zachary Tao on 4/19/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

@MainActor
class ConnectionDetailViewModel: ObservableObject{
    let connectionID: String
    @Published var connection : Connection = Connection()
    @Published var user1 : MomentsUser = MomentsUser(userName: "loading")
    @Published var user2 : MomentsUser = MomentsUser(userName: "loading")
    
    private var db = Firestore.firestore()

    
    init(connectionID: String) {
        self.connectionID = connectionID
        fetchConnection()
    }
    
    private func fetchConnection(){
        Task{
            do{
                let data = try await db.collection("Connections").document(connectionID).getDocument(as: Connection.self)
                
                self.connection = data
                
                guard let userID = Auth.auth().currentUser?.uid else { return }
                var connectUserID = ""
                for id in self.connection.participantsId{
                    if id != userID{
                        connectUserID = id
                    }
                }
                
//                self.user2 = try await db.collection("Users").document(connectUserID).getDocument(as: MomentsUser.self)
//                self.user1 = try await db.collection("Users").document(userID).getDocument(as: MomentsUser.self)
                
                self.user2 = try await db.collection("Users").whereField("userId", isEqualTo:  connectUserID).limit(to: 1).getDocuments().documents.first?.data(as: MomentsUser.self) ?? MomentsUser(userName: "error")
                self.user1 = try await db.collection("Users").whereField("userId", isEqualTo:  userID).limit(to: 1).getDocuments().documents.first?.data(as: MomentsUser.self) ?? MomentsUser(userName: "error")
                
            }catch{
                print("error getting connection data : \(error.localizedDescription)")
            }
        }
        
    }
}
