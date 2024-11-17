//
//  MessageView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 3/23/24.
//

import SwiftUI
import Kingfisher
import FirebaseFirestore

struct PhotoMessageView: View {
    @ObservedObject var photoMessageViewModel : PhotoMessageViewModel
    @GestureState private var gestureZoom = 1.0
    @Binding var selectedMessage: Message?
    var body: some View {
        VStack(spacing: 1){
            headerView
            Group{
                ZStack(alignment: .bottomLeading) {
                    GeometryReader {
                        let size = $0.size
                        KFImage(photoMessageViewModel.message.photoURL)
                            .cacheOriginalImage()
                            .fade(duration: 0.3)
                            .resizable()
                            .scaledToFill()
                            .frame(width: size.width, height: size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .pinchZoom()
                    }.frame(height: 500)

                    Text(photoMessageViewModel.message.caption ?? " ")
                        .foregroundStyle(.white)
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)

                }

                if photoMessageViewModel.messageComments.count > 0{
                    photoCommentDetailView

                }
            }.onTapGesture {
                selectedMessage = photoMessageViewModel.message
            }

        }.padding(0)

    }

    var photoCommentDetailView: some View{
        VStack(alignment: .leading){
            Text("View all ^[\(photoMessageViewModel.messageComments.count) \("comment")](inflect: true)")
                .foregroundStyle(.gray)
            if let mostRecentMessage = photoMessageViewModel.messageComments.sorted(by: {$0.timestamp > $1.timestamp}).first{
                HStack(spacing: 4){
                    Text(photoMessageViewModel.mostRecentCommentUser.userName)
                        .fontWeight(.semibold)
                    Text(mostRecentMessage.comment)
                        .lineLimit(1)
                        .onAppear{
                            photoMessageViewModel.getUserName(userId: mostRecentMessage.senderId ?? "")
                        }
                    Spacer()
                }
            }
        }.padding(10)
            .font(.subheadline)
    }

    var headerView: some View{
        HStack(spacing: 1){
            KFImage(photoMessageViewModel.messageSender.profilePictureURL)
                .setProcessor(DownsamplingImageProcessor(size: CGSize(width: 200, height: 200)))
                .placeholder{
                    Image(systemName: "person.fill")
                        .clipShape(Circle())
                        .frame(width: 50, height: 50)
                }
                .diskCacheExpiration(.days(7))
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
            menuButton.padding(.trailing)
        }.padding(0)
    }

    var menuButton: some View{
        Menu{
            Button{
                guard let url = photoMessageViewModel.message.photoURL else {return}
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
