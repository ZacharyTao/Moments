//
//  HomeView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 3/23/24.
//

import SwiftUI
import Kingfisher


struct PhotoChatView: View {
    
    @StateObject var photosChatViewModel : PhotoChatViewModel
    @StateObject var connectionDetailViewModel : ConnectionDetailViewModel
    
    @Binding var path: NavigationPath

    @State var addAnniversarySheet = false
    @State var showMoodSelectorSheet = false
    @State var selectedMessage: Message?
    
    var body: some View {
        ZoomContainer {
            mainPhotoMessageScrollView
                .ignoresSafeArea(edges: .bottom)
                .toolbar(content: myToolBarContent)
                .sheet(isPresented: $addAnniversarySheet){
                    NewAnniSheetView()
                }
                .sheet(isPresented: $showMoodSelectorSheet){
                    MoodChoosingView()
                }
        }.navigationTitle("")
    }
    
    var connectionDetail: some View{
        VStack{
            moodDisplayView()
                .padding(.vertical)
            ScrollView{
                Button{
                    addAnniversarySheet = true
                }label: {
                    RoundedRectangle(cornerRadius: 25)
                        .shadow(radius: 1)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .overlay(Image(systemName: "plus.app").resizable()
                            .scaledToFit().padding(20))
                        .padding()
                }
            }
        }
    }
    
    var mainPhotoMessageScrollView: some View{
        ScrollView(showsIndicators: false){
            VStack(spacing: 5){
                LazyVStack{
                    ForEach(photosChatViewModel.messages){message in
                        PhotoMessageView(photoMessageViewModel: PhotoMessageViewModel(message: message, connectionId: photosChatViewModel.connectionID), selectedMessage: $selectedMessage)
                            .onAppear{
                                if message.id == photosChatViewModel.messages.last?.id,
                                   photosChatViewModel.messages.count < photosChatViewModel.messageCount
                                {
                                    photosChatViewModel.fetchMessagePaginationVersion()
                                }
                            }
                        Divider()
                    }
                }.padding(3)
                    .onChange(of: photosChatViewModel.messageCount){
                        print("Message count changes from \(photosChatViewModel.messages.count) to \(photosChatViewModel.messageCount)")
                        if photosChatViewModel.messageCount != photosChatViewModel.messages.count
                        {
                            photosChatViewModel.refreshPage()
                        }
                    }
            }
        }
        .navigationDestination(item: $selectedMessage )
        {
            CommentView(photoMessageViewModel: PhotoMessageViewModel(message: $0, connectionId: photosChatViewModel.connectionID))
        }
        .refreshable {
            print("refresh because of refreshable")
            photosChatViewModel.refreshPage()
        }
        .redacted(when: photosChatViewModel.isLoading)
    }
    
    func moodDisplayView() -> some View{
        HStack{
            VStack(spacing: 2){
                profileImage(url: connectionDetailViewModel.user1.profilePictureURL)
                
                Text(connectionDetailViewModel.user1.userName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Button{
                    showMoodSelectorSheet = true
                }label: {
                    HStack{
                        Image(systemName: "pencil")
                        Text("Set mood")
                    } .font(.caption)
                        .padding(5)
                        .background(Color.red.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay{
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.secondary, lineWidth: 1)
                        }
                }
            }
            
            VStack(spacing: 2){
                profileImage(url: connectionDetailViewModel.user2.profilePictureURL)
                Text(connectionDetailViewModel.user2.userName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack{
                    Text("😴")
                    Text("sleep")
                }.padding(5)
                    .font(.caption)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay{
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.secondary, lineWidth: 1)
                    }
            }
            
        }.padding(.horizontal)
        
    }

    @ToolbarContentBuilder
    func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .principal){
            Text(photosChatViewModel.connectUser.userName)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        
        ToolbarItem(placement: .topBarTrailing){
            Button{
                path.append(CurrentView.cameraView)
            }label: {
                Image(systemName: "camera.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .foregroundColor(Color.gray)
            }
        }
    }
    
    func profileImage(url: URL?) -> some View{
        KFImage(url)
            .placeholder{Image(systemName: "person.fill")}
            .resizable()
            .scaledToFill()
            .frame(width: 80, height: 80)
            .clipShape(Circle())
            .overlay{
                Circle().stroke(.black, lineWidth: 2)
            }
            .padding(.horizontal)
    }
}


//
//#Preview {
//    struct preview: View {
//        @State var path = NavigationPath()
//        var body: some View{
//            NavigationStack{
//                PhotoChatView(photosChatViewModel: PhotoChatViewModel(connectionID: ""), path: $path)
//            }
//        }
//    }
//    return preview()
//}
