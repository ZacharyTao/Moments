//
//  UserProfileViewModel.swift
//  MomentsV2
//
//  Created by Zachary Tao on 3/27/24.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import AVKit
import SwiftUI
import FirebaseMessaging

@MainActor
class UserDataManager: ObservableObject{
    @Published var imageData: Data?
    @Published var momentUser = MomentsUser(userName: "")
    @Published private var user: User?
    @Published var connections : [Connection] = []
    

    
    private var userFirebaseDocumentId: String?
    private var db = Firestore.firestore()
    private let storage = Storage.storage()
    
    var errorMessage: String?
    
    init() {
        registerAuthStateHandler()
        fetchMomentUser()
        fetchAllConnections()
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
                self.fetchMomentUser()
            }
        }
    }
    
    private func fetchAllConnections(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Connections")
        .whereField("participantsId", arrayContains: uid)
          .addSnapshotListener { documentSnapshots, error in
              guard let documents = documentSnapshots else {
              print("Error fetching document: \(error!)")
              return
            }
              for document in documents.documents{
                  do{
                      let data = try document.data(as: Connection.self)
                      self.connections.append(data)
                  }catch{
                      print("error getting connection data : \(error.localizedDescription)")
                  }
              }
          }
    }
    
    @MainActor
    func fetchMomentUser(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Users").whereField("userId", isEqualTo: uid)
            .limit(to: 1)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("No documents")
                    return
                }
                
                self.momentUser = documents.compactMap { queryDocumentSnapshot in
                    try? queryDocumentSnapshot.data(as: MomentsUser.self)
                    
                }.first ?? MomentsUser(userName: "")
                self.userFirebaseDocumentId = documents.first?.documentID
                
            }
    }
    
    
    func saveMomentUserInfo() async{
        await storeProfileImage()
        do {
            if let userFirebaseDocumentId{
                try db.collection("Users").document(userFirebaseDocumentId).setData(from: momentUser)
            }
        }
        catch {
            print(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
    
    func storeProfileImage() async {
        guard let imageId = momentUser.userId else { return }
        let imageReference = storage.reference(withPath: "userProfilePictures/\(imageId).png")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        
        guard let imageData else { return }
        guard let uiImage = UIImage(data: imageData)?.resize(500, 500) else {return}
        guard let data = uiImage.jpegData(compressionQuality: 1.0) else {return}
        
        do {
            let _ = try await imageReference.putDataAsync(data, metadata: metaData)
            print("Upload finished.")
            momentUser.profilePictureURL = try await imageReference.downloadURL()
        }
        catch {
            print("An error ocurred while uploading: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    func loadProfileImage(maxRetries: Int = 5, currentAttempt: Int = 1) {
        guard let imageId = user?.uid else { return }
        let maxSize: Int64 = 4 * 1024 * 1024
        let imageReference = storage.reference(withPath: "userProfilePictures/\(imageId).png")
        imageReference.getData(maxSize: maxSize){data, error in
            if let error = error {
                print("Attempt \(currentAttempt): Error downloading image - \(error.localizedDescription)")
                
                if currentAttempt <= maxRetries {
                    let delaySeconds = pow(2.0, Double(currentAttempt))
                    print("Retrying in \(delaySeconds) seconds")
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + delaySeconds) {
                        self.loadProfileImage(maxRetries: maxRetries, currentAttempt: currentAttempt + 1)
                    }
                } else {
                    print("Reached maximum number of retries")
                }
            } else if let data = data {
                self.imageData = data
            }
            
        }
        
    }
    
    func deleteUserFromFirestore(userId: String) async throws {
        if let userFirebaseDocumentId{
            let userDoc = db.collection("Users").document(userFirebaseDocumentId)
            try await userDoc.delete()
        }
    }
    
    // Deletes user's profile picture from Firebase Storage
    func deleteUserProfilePictureFromStorage(userId: String) async throws {
        let storage = Storage.storage()
        let profilePicRef = storage.reference(withPath: "userProfilePictures/\(userId).png")
        
        // Delete the profile picture
        try await profilePicRef.delete()
    }
    
    private  func storeMessageImage(connectionId: String, imageData: Data) async -> URL?{
        let messageId = UUID()
        let imageReference = storage.reference(withPath: "connections/messages/connectionId/\(messageId).png")
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/png"
        
        let uiImage = UIImage(data: imageData)
        guard let data = uiImage?.jpegData(compressionQuality: 0.0) else {return nil}
   
        
        do {
            let resultMetaData = try await imageReference.putDataAsync(data, metadata: metaData)
            print("Upload finished. Metadata: \(resultMetaData)")
            let imageURL = try await imageReference.downloadURL()
            return imageURL
        }
        catch {
            print("An error ocurred while uploading: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }
        return nil
    }
    
    func uploadMessagetoConnection(connectionId: String, photo: Photo) {
        Task{
            let imageURL = await storeMessageImage(connectionId: connectionId, imageData: photo.originalData)
            
            guard let imageURL else {
                print("error storing message image")
                return
            }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let message = Message(senderId: uid, photoURL: imageURL, caption: photo.caption, timestamp: photo.timestamp, location: photo.locationString)
            
            do {
                try db.collection("Connections").document(connectionId).collection("messages").addDocument(from: message)
                
            }
            catch {
                print(error.localizedDescription)
                errorMessage = error.localizedDescription
            }
        }
        
    }
    
    private func pushNotification(recieverToken: String){
        
    }
    
    
}
