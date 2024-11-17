//
//  CommentDetailView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 5/18/24.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher

@MainActor
class CommentDetailViewModel: ObservableObject{
    @Published var comment: MessageComment
    @Published var messageSender: MomentsUser = MomentsUser(userName: " ")
    let db = Firestore.firestore()
    
    init(comment: MessageComment) {
        self.comment = comment
        Task{
            await getUser()
        }
    }
    
    private func getUser() async {
        guard let userId = comment.senderId else {return}
        
        do{
           // let user =  try await db.collection("Users").document(userId).getDocument(as: MomentsUser.self)
            let user = try await db.collection("Users").whereField("userId", isEqualTo: userId).limit(to: 1).getDocuments().documents.first?.data(as: MomentsUser.self) ?? MomentsUser(userName: " ")
            messageSender = user
        }catch{
            print("error getting user for comments \(error.localizedDescription)")
        }
    }
    
   
}

struct CommentDetailView: View {
    @StateObject var vm: CommentDetailViewModel
    var body: some View {
        HStack{
            KFImage(vm.messageSender.profilePictureURL)
                .placeholder{
                    Image(systemName: "person.fill")
                        .clipShape(Circle())
                        .frame(width: 40, height: 40)
                }
                .cacheOriginalImage()
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 40, height: 40)
            VStack(alignment: .leading, spacing: 2){
                HStack(spacing: 2){
                    Text(vm.messageSender.userName)
                    Text(dateDisplayFormatter(vm.comment.timestamp))
                        .foregroundStyle(.gray)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .font(.footnote)
                .fontWeight(.bold)
                Text(vm.comment.comment)
                    .font(.caption)
            }
            Spacer()
        }.padding(.horizontal, 5)
    }
}
