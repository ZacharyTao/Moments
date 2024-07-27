//
//  EditProfileView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 4/11/24.
//

import SwiftUI
import PhotosUI

struct EditProfileView: View {
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @EnvironmentObject var profileViewModel: UserDataManager
    @Binding var path : NavigationPath
    
    
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundStyle(Color.mainColor1)
                .ignoresSafeArea()
            
            VStack{
                Spacer()
                photoPicker
                    .padding(.top, 50)
                Spacer()
                Text("User name")
                    .fontWeight(.medium)
                    .font(.title3)
                TextField(
                    "Type here",
                    text: $profileViewModel.momentUser.userName
                )
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(.horizontal, 15)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray).frame(height: 40))
                .padding()

                
                
                Spacer()
                Spacer()
            }
          
            

        }
        .navigationBarBackButtonHidden()
        .toolbar{
            ToolbarItem(placement: .topBarLeading){
                Button{
                    path.removeLast()
                }label: {
                    Text("Cancel")
                        .foregroundColor(.black)
                }
            }
            
            ToolbarItem(placement: .principal){
                Text("Edit Profile")
                    .fontWeight(.bold)
                    .font(.title3)
            }
            
            ToolbarItem(placement: .topBarTrailing){
                Button{
                    Task{
                        await profileViewModel.saveMomentUserInfo()
                    }
                    path.removeLast()
                } label: {
                    Text("Save")
                        .foregroundColor(.black)
                }
            }
            
        }
        
        
        
    }
    
    
    
    var photoPicker: some View{
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()) {
                if let selectedImageData = profileViewModel.imageData,
                   let uiImage = UIImage(data: selectedImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 175, height: 175 )
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black, lineWidth: 4))
                    
                }else{
                    ProgressView()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 175, height: 175 ).fontWeight(.ultraLight)
                }
                
            }
        
            .overlay{
                Circle().stroke(.black, lineWidth: 4)
            }
            .overlay{
                Circle()
                    .stroke(.black, lineWidth: 4)
                    .fill(.white)
                    .frame(width: 40)
                    .overlay{
                        Image(systemName: "camera.fill")
                            .frame(width: 35)
                            .background(.clear)
                    }
                    .offset(CGSize(width: 60, height: 55))
            }
            .onChange(of: selectedItem) { (_, newItem) in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        profileViewModel.imageData = data
                    }
                }
            }
    }
}

#Preview {
    struct preview: View{
        @State var path = NavigationPath()
        var body: some View{
            NavigationStack{
                EditProfileView(path: $path)
                    .environmentObject(UserDataManager())
            }
        }
    }
    return preview()
}
