//
//  ChatViewModel.swift
//  MomentsV2
//
//  Created by Zachary Tao on 3/23/24.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseAuth
import Photos


@MainActor
class PhotoChatViewModel: ObservableObject{

    @Published var connection : Connection
    @Published var connectUser : MomentsUser = MomentsUser(userName: "")
    @Published var messages : [Message] = []
    @Published var connectionID: String
    @Published var errorMessage: String?
    @Published var messageCount = 0
    @Published var isLoading = true
    @Published var latestMessage: Message = Message(senderId: "Error")

    private var lastDocument: DocumentSnapshot? = nil

    private var listenerRegistration: ListenerRegistration?
    private var db = Firestore.firestore()


    init(connectionID: String) {
        self.connectionID = connectionID
        self.connection = Connection()

        fetchConnection()
        fetchMessageCount()

        // fetchMessages()
        isLoading = false
    }

    public func fetchMessageCount() {
        db.collection("Connections").document(connectionID).collection("messages")
            .addSnapshotListener{
                documentSnapshot, error in
                guard let documents = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                self.messageCount = documents.count
            }
    }

    public func refreshPage(){
        isLoading = true
        lastDocument = nil
        messages = []
        fetchMessages()
        // fetchMessagePaginationVersion()
        isLoading = false
    }

    func fetchMessages() {
        Task {
            do {
                let documents = try await db.collection("Connections").document(connectionID).collection("messages")
                    .order(by: "timestamp", descending: true)
                    .getDocuments()
                self.messages = documents.documents.compactMap { document in
                    return try? document.data(as: Message.self)
                }
            }
        }
    }

    func fetchMessagePaginationVersion(){
        Task{
            do{
                if let lastDocument{
                    let documents = try await db.collection("Connections").document(connectionID).collection("messages")
                        .order(by: "timestamp", descending: true)
                        .limit(to: 3)
                        .start(afterDocument: lastDocument)
                        .getDocuments()
                    let newMessages = documents.documents.compactMap { document in
                        return try? document.data(as: Message.self)
                    }
                    messages.append(contentsOf: newMessages)
                    self.lastDocument = documents.documents.last
                }else{
                    let documents = try await db.collection("Connections").document(connectionID).collection("messages")
                        .order(by: "timestamp", descending: true)
                        .limit(to: 3)
                        .getDocuments()
                    let newMessages = documents.documents.compactMap { document in
                        return try? document.data(as: Message.self)
                    }
                    messages.append(contentsOf: newMessages)
                    self.lastDocument = documents.documents.last
                }
            }catch{
                print("Message fetch error")
            }
        }
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
                self.connectUser = try await db.collection("Users").whereField("userId", isEqualTo: connectUserID).limit(to: 1).getDocuments().documents.first?.data(as: MomentsUser.self) ?? MomentsUser(userName: "Error: user account might be deleted")
            }catch{
                print("error getting connection data : \(error.localizedDescription)")
            }
        }

    }

}
