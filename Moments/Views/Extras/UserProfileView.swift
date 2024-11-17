//
//  UserProfileView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 3/23/24.
//

import SwiftUI
import PhotosUI
import Kingfisher

struct UserProfileView: View{
    
    @Environment(AuthManager.self) var authManager
    @EnvironmentObject var userDataManager: UserDataManager
    
    @Binding var path : NavigationPath
    @Environment(\.dismiss) var dismiss
    @State var presentingConfirmationDialog = false
    
    var body: some View{
        ZStack{
            Rectangle()
                .foregroundStyle(Color.mainColor1)
                .ignoresSafeArea()
            content
        }
        .navigationBarTitle(Text(""), displayMode: .inline)
        .toolbar{
            ToolbarItem(placement: .principal){
                Text("Profile")
                    .fontWeight(.bold)
                    .font(.title2)
                    .foregroundStyle(.black)
            }
            ToolbarItem(placement: .topBarTrailing){
                Button{
                    path.append(CurrentView.editProfileView)
                }label: {
                    Text("Edit")
                        .foregroundStyle(.black)
                }
            }
        }
        .onAppear{
            Task{
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                userDataManager.loadProfileImage()
            }
        }

        .confirmationDialog("Deleting your account is permanent. Do you want to delete your account?",
                            isPresented: $presentingConfirmationDialog, titleVisibility: .visible) {
            Button("Delete Account", role: .destructive, action: deleteAccount)
            Button("Cancel", role: .cancel, action: { })
        }
    }
    
    
    var content: some View{
        
        VStack(alignment: .center){
            
            
            Spacer()
            photoView
                .padding(.top, 50)
            
            
            Text(userDataManager.momentUser.userName)
                .font(.title2)
                .fontWeight(.bold)
            Text("MomentID: \(userDataManager.momentUser.uniqueID)")
                .font(.caption)
                .foregroundStyle(.gray)
            
            Spacer()
            
            
            
            
            Spacer()
            connectButton
            RoundedRectangle(cornerRadius: 1)
                .foregroundStyle(.black.opacity(0.5))
                .frame(height: 2)
                .padding()
            signOutButton
            deleteButton
            
        }
        .padding(.vertical, 0)
        .padding()
        
    }
    
    var connectButton: some View{
        Button{
            path.append(CurrentView.connectionView)
        }label:{
            Text("Add connections")
                .fontWeight(.semibold)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 50)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1.5))
        }
    }
    
    var deleteButton: some View{
        Button(role: .destructive){
            presentingConfirmationDialog.toggle()
        }label:{
            Text("Delete account")
                .fontWeight(.semibold)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 50)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1.5))
        }
    }
    
    var signOutButton: some View{
        Button{
            authManager.signOut()
        }label: {
            Text("Sign out")
                .fontWeight(.semibold)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 50)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1.5))
                .foregroundStyle(.black)
            
        }
        
    }
    
    
    
    var photoView: some View{
        Group{
            KFImage(userDataManager.momentUser.profilePictureURL)
                .resizable()
                .scaledToFill()
                .frame(width: 175, height: 175 )
                .clipShape(Circle())
//            if let selectedImageData = profileViewModel.imageData,
//               let uiImage = UIImage(data: selectedImageData) {
//                Image(uiImage: uiImage)
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width: 175, height: 175 )
//                    .clipShape(Circle())
//            }else{
//                ProgressView()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(width: 175, height: 175 ).fontWeight(.ultraLight)
//                
//            }
        }
        .overlay{
            Circle().stroke(.black, lineWidth: 4)
        }
    }
    
    private func deleteAccount() {
        Task {
            do{
                if await authManager.deleteAccount() == true {
                    if let userId = userDataManager.momentUser.id{
                        try await userDataManager.deleteUserFromFirestore(userId: userId)
                        try await userDataManager.deleteUserProfilePictureFromStorage(userId: userId)
                    }
                }
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
}




#Preview {
    struct preview: View {
        @State var path = NavigationPath()
        var body: some View{
            NavigationStack{
                UserProfileView(path: $path)
                    .environment(AuthManager())
                    .environmentObject(UserDataManager())
            }
        }
    }
    return preview()
}


