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
    @EnvironmentObject var infoViewModel : SignUpInfoViewModel
    @State var disableContinueButton = true
    @Binding var viewLogic: HomeView.homeViewLogic
    
    var body: some View {
        GeometryReader{geometry in
            ZStack{
                VStack(alignment: .center){
                    Spacer()
                    Text("Welcome to Moments!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    photoPicker
                        .onChange(of: selectedItem) { (_, newItem) in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    infoViewModel.imageData = data
                                }
                            }
                        }
                    
                    TextField(
                        "Type in your user name",
                        text: $infoViewModel.momentUser.userName
                    )
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .padding(.horizontal, 15)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray).frame(height: 40))
                    .padding()
//                    
//                        LimitedTextField(
//                            config: .init(
//                                limit: 12,
//                                tint: .secondary,
//                                autoResizes: true,
//                                allowsExcessTyping: false,
//                                progressConfig: .init(
//                                    showsRing: true,
//                                    showsText: false
//                                ),
//                                borderConfig: .init(
//                                    radius: 10
//                                )
//                            ),
//                            hint: "Type in your user name",
//                            value: $infoViewModel.momentUser.userName
//                        )
//                        .autocorrectionDisabled()
//                        .textInputAutocapitalization(.never)
//                        .padding(.horizontal, 15)
//                        .padding(.vertical, 20)
//                        
//                        

                    Spacer()
                    
                    Button("Continue"){
                        Task{
                            await infoViewModel.saveMomentUserInfo()
                        }
                        viewLogic = .appView
                    }
                }
                .background(.white)
            }
        }
    }
    
    var photoPicker: some View{
        PhotosPicker(
            selection: $selectedItem,
            matching: .images,
            photoLibrary: .shared()) {
                if let selectedImageData = infoViewModel.imageData,
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
                        .frame(width: 200, height: 200 ).fontWeight(.ultraLight)
                    
                }
                
            }
    }
}




#Preview {
    SignUpInfoView(viewLogic: .constant(.signUpInfo))
        .environmentObject(SignUpInfoViewModel())
}


