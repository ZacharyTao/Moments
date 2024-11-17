//
//  UserManager.swift
//  Moments
//
//  Created by Zachary Tao on 11/16/24.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

final class UserManager {
    static let shared = UserManager()
    var errorMessage = ""
    let db = Firestore.firestore()
    var userID: String { Auth.auth().currentUser?.uid ?? "" }

    private var currentUser: MomentsUser?

    private init () {}

    // Expose current user
    func getCurrentUser() -> MomentsUser? {
        return currentUser
    }

    // Update the user info and refresh cache
    func updateUserInfo(updatedUser: MomentsUser) async -> Bool {
        do {
            try db.collection("Users").document(userID).setData(from: updatedUser, merge: true)
            currentUser = updatedUser
            return true
        } catch {
            errorMessage = error.localizedDescription
            print(errorMessage)
            return false
        }
    }

    // Fetch and cache the user info
    // called when account is logged in
    func fetchUser() async {
        do {
            currentUser = try await db.collection("Users").document(userID).getDocument().data(as: MomentsUser.self)
        } catch {
            errorMessage = error.localizedDescription
            print(errorMessage)
        }
    }

    // Create a new user and cache it
    func createNewUser(newUser: MomentsUser) async {
        do {
            print("User id: \(userID) is created in the database")
            try db.collection("Users").document(userID).setData(from: newUser)
            currentUser = newUser
        } catch {
            errorMessage = error.localizedDescription
            print(errorMessage)
        }
    }

    func saveUserProfilePicture(imageData: Data?) async -> URL {
        guard let imageData else { return URL(string: "")! }
        let imageId = userID
        let imageReference = Storage.storage().reference(withPath: "userProfilePictures/\(imageId).png")

        let metaData = StorageMetadata()
        metaData.contentType = "image/png"

        do {
            let resultMetaData = try await imageReference.putDataAsync(imageData, metadata: metaData)
            print("Upload finished. Metadata: \(resultMetaData)")
            return try await imageReference.downloadURL()
        }
        catch {
            errorMessage = error.localizedDescription
            print("An error ocurred while uploading: \(errorMessage)")
            return URL(string: "")!
        }
    }

    // Delete the user info
    func deleteUserInfo(userIDTarget: String) {
        db.collection("users").document(userIDTarget).delete()
        currentUser = nil
    }
}

