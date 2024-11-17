//
//  ConnectingViewModek.swift
//  MomentsV2
//
//  Created by Zachary Tao on 4/5/24.
//

import Foundation
import FirebaseFirestore

import FirebaseAuth
import FirebaseFirestoreSwift

@MainActor
final class ConnectingViewModel: ObservableObject{
    @Published var connectingUser : MomentsUser?
    @Published var bondID = ""
    let db = Firestore.firestore()
    @Published var invites: [Invitation] = []
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    @Published private var currentUser: User?
    
    init(){
        registerAuthStateHandler()
    }
    
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.currentUser = user
                Task{
                    await self.fetchInvitation(recieverId: self.currentUser?.uid)
                }
            }
        }
    }
    
    func acceptInvitation(invitationId: String?){
        guard let invitationId else {return}
        Task{
            do{
                let invitation = try await db.collection("Invitations").document(invitationId).getDocument(as: Invitation.self)
                if let senderID = invitation.senderId,
                   let recieverID = invitation.recieverId{
                    let connection = Connection(participantsId: [senderID, recieverID])
                    try db.collection("Connections").addDocument(from: connection)
                    await deleteInvitation(invitationId: invitationId)
                }
            }catch{
                print("error accepting invitation \(error.localizedDescription)")
            }
        }
    }
    
    func deleteInvitation(invitationId: String?) async{
        guard let invitationId else {return }
        do {
          try await db.collection("Invitations").document(invitationId).delete()
          print("Document successfully removed!")
        } catch {
          print("Error removing document: \(error)")
        }
    }
    
    func fetchInvitation(recieverId: String?) async {
        guard let recieverId else {return}
        invites = []

        db.collection("Invitations").whereField("recieverId", isEqualTo: recieverId)
          .addSnapshotListener { querySnapshot, error in
              guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                  }
              do{
                  for document in documents {
                      try self.invites.append(document.data(as: Invitation.self))
                  }
              }catch{
                  print("error appending invite \(error.localizedDescription)")
              }
                  
          }
    }

    func searchUserWithMomentID(){
        db.collection("Users").whereField("uniqueID", isEqualTo: bondID).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                self.connectingUser = nil
            } else {
                for document in querySnapshot!.documents {
                    Task {
                        do {
                            let user = try document.data(as: MomentsUser.self)
                            self.connectingUser = user
                        }
                        catch {
                            self.connectingUser = nil
                            print(error)
                        }
                    }
                    
                }
            }
        }
    }
    
    
    func sendInvitationRequest(sender: MomentsUser, recieverUniqueId: String){
        db.collection("Users").whereField("uniqueID", isEqualTo: recieverUniqueId)
            .getDocuments(){(querySnapshot, error) in
                if let error = error{
                    print("error getting recieverID \(error.localizedDescription)")
                }else{
                    for document in querySnapshot!.documents {
                        Task {
                            do {
                                let reciever = try document.data(as: MomentsUser.self)
                                let invite = Invitation(senderProfilePictureURL: sender.profilePictureURL, senderName: sender.userName, senderId: sender.id, recieverId: reciever.id)
                                print("sender name is \(sender.userName)")
                                try self.db.collection("Invitations").addDocument(from: invite)
                            }
                            
                            catch {
                                print(error)
                            }
                        }
                        
                    }
                }
            }
    }
    
    
}
