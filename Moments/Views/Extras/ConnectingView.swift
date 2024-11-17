//
//  ConnectingView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 4/4/24.
//

import SwiftUI


struct ConnectingView: View {
    @EnvironmentObject var userData : UserDataManager
    @State private var isEditing = false
    @StateObject var connectingViewModel = ConnectingViewModel()
    @State private var isButtonEnabled = true
    @Binding var path: NavigationPath
    var body: some View {
        VStack{
            headerView
            searchBar
            
            searchedPersonView
            
            Spacer()
            
            RoundedRectangle(cornerRadius: 2)
                .frame(height: 2)
                .foregroundStyle(.gray.opacity(0.6))
                
            invitationView
            
        }.padding()
            .background(Color.mainColor1)
            .ignoresSafeArea(.keyboard)
            .navigationBarTitle(Text(""), displayMode: .inline)

    }
    
    @ViewBuilder
    var searchedPersonView: some View{
        if let user = connectingViewModel.connectingUser,
           user.uniqueID != userData.momentUser.uniqueID{
            searchUserView(user)
            Spacer()
            Button{
                isButtonEnabled = false
                connectingViewModel.sendInvitationRequest(sender: userData.momentUser, recieverUniqueId: connectingViewModel.bondID)
            }label: {
                if isButtonEnabled{
                    Text("Send Invitation")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1.5))
                }else{
                    HStack{
                        Text("Sent")
                        Image(systemName: "checkmark.circle.fill")
                    }.fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1.5))
                        .foregroundStyle(.black)
                }
                
            }.disabled(!isButtonEnabled)
        }
    }
    
    @ViewBuilder
    var invitationView: some View{
        
        Text("Invitation Requests")
            ForEach(connectingViewModel.invites){invite in
                HStack{
                    AsyncImage(url: invite.senderProfilePictureURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 40)
                                .clipShape(Circle())
                        case .success(let image):
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.black, lineWidth: 4))
                        case .failure:
                            Image(systemName: "person")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40)
                            
                        @unknown default:
                            EmptyView()
                        }
                    }
                    Text(invite.senderName ?? "")
                    Spacer()
                    
                    Button{
                        withAnimation{connectingViewModel.invites.removeAll {$0 == invite}}
                        connectingViewModel.acceptInvitation(invitationId: invite.id)
                    }label: {
                        Text("Accept")
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                            .padding(7)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1.5))
                            .background(.black)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Button{
                        withAnimation{connectingViewModel.invites.removeAll {$0 == invite}}
                        Task{
                            await connectingViewModel.deleteInvitation(invitationId: invite.id)
                        }
                    }label: {
                        Text("Delete")
                            .fontWeight(.semibold)
                            .padding(7)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(lineWidth: 1.5))
                            .foregroundStyle(.black)
                    }
                    
                    
                }
            }
    }
    
    var headerView: some View{
        HStack{
            VStack(alignment: .leading){
                Text("Connect to another user")
                    .font(.title)
                    .fontWeight(.bold)
                Text("Your MomentID: \(userData.momentUser.uniqueID)")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Spacer()
        }
    }
    
    var searchBar: some View{
        HStack{
            TextField("Search MomentID", text: $connectingViewModel.bondID)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal, 10)
                .onTapGesture {
                    withAnimation{
                        self.isEditing = true
                    }
                }
                .onChange(of: connectingViewModel.bondID){
                    if connectingViewModel.bondID.count != 6{
                        connectingViewModel.connectingUser = nil
                    }else{
                        connectingViewModel.searchUserWithMomentID()
                    }
                }
                .autocorrectionDisabled()
            
        }.overlay(
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 17)
                
                if isEditing {
                    Button(action: {
                        connectingViewModel.bondID = ""
                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                            .padding(.trailing, 17)
                    }
                }
            }
        )
    }
    
    func searchUserView(_ user: MomentsUser) -> some View{
        VStack{
            Spacer()
            AsyncImage(url: user.profilePictureURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 250)
                        .clipShape(Circle())
                case .success(let image):
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 250)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.black, lineWidth: 4))
                case .failure:
                    Image(systemName: "photo")
                        .frame(width: 250)
                        .clipShape(Circle())
                @unknown default:
                    EmptyView()
                }
            }
            
            Text(user.userName)
                .font(.title2)
                .fontWeight(.medium)
            Spacer()
            
        }
    }
    
    
}

#Preview {
    struct preview: View{
        @State var path = NavigationPath()
        var body: some View{
            NavigationStack{
                ConnectingView(path: $path)
                    .environmentObject(UserDataManager())
            }
        }
    }
    return preview()
}
