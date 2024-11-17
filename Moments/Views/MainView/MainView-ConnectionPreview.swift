//
//  MainView-ConnectionPreview.swift
//  MomentsV2
//
//  Created by Zachary Tao on 4/14/24.
//

import SwiftUI
import Kingfisher

struct MainView_ConnectionPreview: View {
    
    var connection: MainViewModel.ConnectionPreview
    
    var body: some View {
        VStack(spacing: 2){
            HStack(spacing: 3){
                KFImage(connection.recieverProfilePhoto)
                    .cacheOriginalImage()
                    .fade(duration: 0.3)
                    .diskCacheExpiration(.days(7))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())

                Text(connection.recieverName)
                    .fontWeight(.semibold)
                    .font(.caption)
                Spacer()
            }
   
            ZStack(alignment: .bottomLeading){

                if let url = connection.lastPhotoURL{
                    KFImage(url)
                        .cacheOriginalImage()
                        .fade(duration: 0.3)
                        .diskCacheExpiration(.days(7))
                        .resizable()
                        .scaledToFit()
                        //  .aspectRatio(3.3/4, contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }else{
                    RoundedRectangle(cornerRadius: 15)
                        // .aspectRatio(3.3/4, contentMode: .fit)
                        .scaledToFit()
                        .foregroundStyle(.gray.opacity(0.2))
                }
                
                if let caption = connection.lastCaption,
                   !caption.trimmingCharacters(in: .whitespaces).isEmpty{
                    Text(caption)
                        .foregroundStyle(.white)
                        .font(.caption)
                        .padding(.vertical, 5)
                        .padding(.horizontal, 8)
                }else{
                    Text("  ")
                        .foregroundStyle(.white)
                        .padding(5)
                }
            }
            
        }.padding(0)
    }
}

#Preview {
    MainView_ConnectionPreview(connection: MainViewModel.ConnectionPreview(connectionID: "EiS0k2IJ94qdBccPBk3k", recieverName: "sydney"))
}
