//
//  CommentView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 5/18/24.
//

import SwiftUI
import Kingfisher

struct CommentView: View {
    @ObservedObject var photoMessageViewModel : PhotoMessageViewModel
    @GestureState private var gestureZoom = 1.0
    @Environment(\.dismiss) var dismiss
    @State var commentInput = ""
    @FocusState var isFocused:Bool
    var body: some View {
        ZoomContainer{
            VStack{
                ScrollView{
                    headerView
                    VStack(spacing: 0){
                        GeometryReader {
                            let size = $0.size
                            KFImage(photoMessageViewModel.message.photoURL)
                                .cacheOriginalImage()
                                .resizable()
                                .scaledToFill()
                                .frame(width: size.width, height: size.height)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .pinchZoom()
                        }.frame(height: 500)
                        
                        Text(photoMessageViewModel.message.caption ?? "")
                            .foregroundStyle(.black)
                            .font(.system(size: 20))
                            .fontWeight(.medium)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        Divider()
                    }
                    
                    
                    ForEach(photoMessageViewModel.messageComments.sorted(by: {$0.timestamp < $1.timestamp})){com in
                        CommentDetailView(vm: CommentDetailViewModel(comment: com))
                    }
                }.padding(0)
                    .scrollIndicators(.hidden)
                    .scrollDismissesKeyboard(.interactively)
                    .defaultScrollAnchor(.bottom)

                HStack{
                    TextField("Enter Message", text: $commentInput)
                        .focused($isFocused)
                        .padding(.horizontal)
                        .frame (height: 45)
                        .background (Color.primary.opacity(0.06))
                        .clipShape (Capsule())
                    Image(systemName: "paperplane.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame (height: 40)
                        .foregroundStyle(Color.second)
                        .onTapGesture {
                            photoMessageViewModel.submitNewComment(text: commentInput)
                            commentInput = ""
                        }
                }.padding(2)
            }.padding(.horizontal, 2)
                .navigationTitle("")
        }
    }
    
    var headerView: some View{
        HStack(spacing: 1){
            KFImage(photoMessageViewModel.messageSender.profilePictureURL)
                .placeholder{
                    Image(systemName: "person.fill")
                }
                .cacheOriginalImage()
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 50, height: 50)
            
            
            VStack(alignment: .leading){
                Text(photoMessageViewModel.messageSender.userName)
                    .fontWeight(.semibold)
                HStack(spacing: 1){
                    Text(dateDisplayFormatter(photoMessageViewModel.message.timestamp))
                    if let loc = photoMessageViewModel.message.location,
                       !loc.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    {
                        Text("·")
                        Text(loc)
                    }
                }.foregroundStyle(.gray)
                    .font(.system(size: 13))
                    .fontWeight(.semibold)
                    .lineLimit(1)
            }.padding(0)
            Spacer()
            menuIcon.padding(.trailing)
            
        }.padding(0)
    }
    
    var menuIcon: some View{
        Menu{
            Button{
                guard let url = photoMessageViewModel.message.photoURL else{return}
                photoMessageViewModel.downloadImage(from: url) { image in
                    DispatchQueue.main.async {
                        if let image = image {
                            photoMessageViewModel.saveImageToPhotoLibrary(image)
                        } else {
                            print("Failed to download image.")
                        }
                    }
                }
                
            }label: {
                Label("Save Photo", systemImage: "square.and.arrow.down")
                
            }
            
            if photoMessageViewModel.isUserMessage{
                Button (role: .destructive){
                    Task{
                        await photoMessageViewModel.deleteMessageFromFirebase(connectionID: photoMessageViewModel.connectionId)
                    }
                } label: {
                    Label("Delete Photo", systemImage: "trash")
                }
            }
            
        }label:{
            Image(systemName: "ellipsis")
                .foregroundColor(.primary)
                .font(.title3)
            
        }
    }
}

//#Preview {
//    CommentView(photoView: Image("sampleImage"))
//}
