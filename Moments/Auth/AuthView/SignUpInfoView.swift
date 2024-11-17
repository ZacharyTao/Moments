//
//  SignUpInfoView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 3/24/24.
//

import SwiftUI
import PhotosUI


struct SignUpInfoView: View {
    @State private var selectedItem: PhotosPickerItem? = nil

    @State var imageData: Data?
    @State var userName = ""

    @Binding var viewLogic: HomeView.homeViewLogic

    var body: some View {
        ScrollView{
            VStack(spacing: 30){
                Text("Welcome to Moments!")
                    .font(.largeTitle.bold())
                    .padding(.vertical, 50)
                Spacer(minLength: 50)

                photoPicker
                    .onChange(of: selectedItem) { (_, newItem) in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) { imageData = data }
                        }
                    }

                TextField(
                    "Type in your user name",
                    text: $userName
                )
                .frame(height: 50)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 10)
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary))
                .padding(.horizontal, 20)

                Spacer(minLength: 50)

                Button("Continue"){
                    Task{
                        let profileImageURL = await UserManager.shared.saveUserProfilePicture(imageData: imageData)
                        let newUser = MomentsUser(userName: userName, profilePictureURL: profileImageURL)
                        await UserManager.shared.createNewUser(newUser: newUser)
                    }
                    viewLogic = .appView
                }
                .font(.title3.bold())
                .frame(width: 300, height: 50)
                .foregroundStyle(.white)
                .background(Color.second)
                .cornerRadius(10)
                .padding(40)
            }
        }
    }

    var photoPicker: some View{
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()) {
                if let selectedImageData = imageData,
                   let uiImage = UIImage(data: selectedImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200 )
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black, lineWidth: 4))

                }else{
                    Image(systemName: "person.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.black)
                        .frame(width: 200, height: 200)
                        .fontWeight(.ultraLight)
                }
            }
    }
}




#Preview {
    SignUpInfoView(viewLogic: .constant(.signUpInfo))
}


