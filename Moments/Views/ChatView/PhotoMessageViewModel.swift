//
//  MessageViewModel.swift
//  MomentsV2
//
//  Created by Zachary Tao on 4/16/24.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import Photos
import Foundation

@MainActor
final class PhotoMessageViewModel: ObservableObject{
    @Published var message: Message
    @Published var messageSender = MomentsUser(userName: " ")
    @Published var isUserMessage: Bool = false
    @Published var messageComments: [MessageComment] = []
    @Published var mostRecentCommentUser = MomentsUser(userName: " ")
    var db = Firestore.firestore()
    var connectionId: String = ""
    var connection = Connection()
    
    init(message: Message, connectionId: String) {
        self.message = message
        self.connectionId = connectionId
        
        Task{
            await fetchMessageUserInfo()
            await fetchConnection()
        }
        checkMessageUser()
        fetchComments()
    }
    
    private func fetchConnection() async {
        do{
            connection = try await db.collection("Connections").document(connectionId).getDocument(as: Connection.self)
        }catch{
            print("Error fetching connection \(error.localizedDescription)")
        }
    }
    
    private func checkMessageUser(){
        guard let userID = Auth.auth().currentUser?.uid else { return }
        isUserMessage = message.senderId == userID
    }
    
    func deleteMessageFromFirebase(connectionID: String) async{
        guard let messageId = message.id else{ print("error deleting image")
            return}
        do {
            try await db.collection("Connections").document(connectionID).collection("messages").document(messageId).delete()
        } catch {
            print("Error removing document: \(error)")
        }
    }
    
    
    private func fetchMessageUserInfo() async{
        let userId = message.senderId
        
        let docRef = db.collection("Users").whereField("userId", isEqualTo: userId).limit(to: 1)
        
        do {
            //let messageSenderUser = try await docRef.getDocument(as: MomentsUser.self)
            messageSender = try await docRef.getDocuments().documents.first?.data(as: MomentsUser.self) ?? MomentsUser(userName: "Error")
            
        } catch {
            print("Error getting document: \(error)")
        }
        
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil, let image = UIImage(data: data) else {
                print("Error downloading image: \(String(describing: error))")
                completion(nil)
                return
            }
            completion(image)
        }.resume()
    }
    
    func saveImageToPhotoLibrary(_ image: UIImage) {
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { success, error in
            if let error = error {
                print("Error saving image to photo library: \(error)")
            } else {
                print("Successfully saved image to photo library")
            }
        }
    }
    
    func getUserName(userId: String) {
        let db = Firestore.firestore()
        Task{
            do{
                let user = try await db.collection("Users").whereField("userId", isEqualTo: userId).limit(to: 1).getDocuments().documents.first?.data(as: MomentsUser.self)
                mostRecentCommentUser = user ?? MomentsUser(userName: "")
            }catch{
                print("error getting user name \(error.localizedDescription)")
            }
        }
    }
    
    func submitNewComment(text: String){
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let partipants = connection.participantsId
        
        let recieverId = partipants.first(where: {$0 != userID}) ?? ""
        
        print("recieverId is \(recieverId)")
        let newComment = MessageComment(messageId: message.id, senderId: userID, recieverId: recieverId, comment: text, timestamp: Date())
        do{
            try db.collection("MessageComments").addDocument(from: newComment)
        }catch{
            print("Error posting comment \(error.localizedDescription)")
        }
    }
    
    private func fetchComments() {
        db.collection("MessageComments").whereField("messageId", isEqualTo: message.id ?? "")
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot else {
                      print("Error fetching commments: \(error!)")
                      return
                    }
                
                documents.documentChanges.forEach{ document in
                    if document.type == .added{
                        let msg = try! document.document.data(as: MessageComment.self)
                        DispatchQueue.main.async {
                            self.messageComments.append(msg)
                        }
                        
                    }
                }
            }
    }
}
