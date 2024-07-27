//
//  SignUpInfoViewModel.swift
//  MomentsV2
//
//  Created by Zachary Tao on 3/24/24.
//

import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseMessaging
import AVKit
import SwiftUI

@MainActor
class SignUpInfoViewModel: ObservableObject{
    @Published var imageData: Data?
    @Published var momentUser = MomentsUser(userName: "")
    @Published private var user: User?
    private var db = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    private var FCMtoken : String?
    
    init() {
        registerAuthStateHandler()
        $user
            .compactMap { $0 }
            .sink { user in
                self.momentUser.userId = user.uid
            }
            .store(in: &cancellables)
    }
    
    private func getFCMtoken(){
        Messaging.messaging().token{token, error in
            if let error = error{
                print("Error fetching FCM registration token: \(error.localizedDescription)")
            }else if let token = token{
                self.FCMtoken = token
                self.momentUser.FCMtoken = token
            }
        }
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
            }
        }
    }
    
    func saveMomentUserInfo() async{
        do {
           // getFCMtoken()
            if let documentId = momentUser.id {
                await storeProfilePicture()
                try db.collection("Users").document(documentId).setData(from: momentUser)
            }
            else {
                await storeProfilePicture()
                try db.collection("Users").addDocument(from: momentUser)
                print(momentUser)
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func checkIfMomentsUserExists() async -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false}
        
            do {
                let querySnapshot = try await db.collection("Users").whereField("userId", isEqualTo: uid).limit(to: 1).getDocuments()
                return !querySnapshot.isEmpty
                
            }
            catch {
                print(error.localizedDescription)
            }
            
            print("user is not found")
            return false
        }

    
    func storeProfilePicture() async {
      guard let imageId = momentUser.userId else { return }
      let imageReference = Storage.storage().reference(withPath: "userProfilePictures/\(imageId).png")

      let metaData = StorageMetadata()
      metaData.contentType = "image/png"

      guard let imageData else { return }

      do {
        let resultMetaData = try await imageReference.putDataAsync(imageData, metadata: metaData)
        print("Upload finished. Metadata: \(resultMetaData)")
        momentUser.profilePictureURL = try await imageReference.downloadURL()
      }
      catch {
        print("An error ocurred while uploading: \(error.localizedDescription)")
      }
    }
    
}

