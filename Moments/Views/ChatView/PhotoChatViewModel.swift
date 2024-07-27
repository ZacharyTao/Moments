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
    @Published var isLoading = false
    @Published var latestMessage: Message = Message(senderId: "Error")
    
    private var lastDocument: DocumentSnapshot? = nil
    
    private var listenerRegistration: ListenerRegistration?
    private var db = Firestore.firestore()
    
    
    init(connectionID: String) {
        self.connectionID = connectionID
        self.connection = Connection()
        //   fetchFirstMessageRealTime()
        fetchConnection()
        fetchMessageCount()
        
        
        // refreshPage()
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
        fetchMessagePaginationVersion()
        isLoading = false
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
                isLoading = false
                
            }catch{
                print("Message fetch error")
            }
        }
    }
    
    func fetchFirstMessageRealTime(){
        if listenerRegistration == nil {
            listenerRegistration = db.collection("Connections").document(connectionID).collection("messages").order(by: "timestamp", descending: true)
                .limit(to: 1)
                .addSnapshotListener { [weak self] (querySnapshot, error) in
                    
                    guard let documents = querySnapshot?.documents else {
                        self?.errorMessage = "No documents in collection"
                        return
                    }
                    let newMessages = documents.compactMap { queryDocumentSnapshot in
                        let result = Result { try queryDocumentSnapshot.data(as: Message.self) }
                        
                        switch result {
                        case .success(let message):
                            self?.errorMessage = nil
                            return message
                        case .failure(let error):
                            // A value could not be initialized from the DocumentSnapshot.
                            switch error {
                            case DecodingError.typeMismatch(_, let context):
                                self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                            case DecodingError.valueNotFound(_, let context):
                                self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                            case DecodingError.keyNotFound(_, let context):
                                self?.errorMessage = "\(error.localizedDescription): \(context.debugDescription)"
                            case DecodingError.dataCorrupted(let key):
                                self?.errorMessage = "\(error.localizedDescription): \(key)"
                            default:
                                self?.errorMessage = "Error decoding document: \(error.localizedDescription)"
                            }
                            return nil
                        }
                    }
                    self?.latestMessage = newMessages[0]
                }
            
        }
    }
    
    
    //    public func unsubscribe() {
    //        if listenerRegistration != nil {
    //            listenerRegistration?.remove()
    //            listenerRegistration = nil
    //        }
    //    }
    
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
                
//                self.connectUser = try await db.collection("Users").document(connectUserID).getDocument(as: MomentsUser.self)
                self.connectUser = try await db.collection("Users").whereField("userId", isEqualTo: connectUserID).limit(to: 1).getDocuments().documents.first?.data(as: MomentsUser.self) ?? MomentsUser(userName: "Error: user account might be deleted")

                
            }catch{
                print("error getting connection data : \(error.localizedDescription)")
            }
        }
        
    }
    
}
