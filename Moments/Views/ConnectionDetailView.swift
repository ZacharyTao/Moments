//
//  ConnectionDetailView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 4/18/24.
//

import SwiftUI
import Kingfisher

struct ConnectionDetailView: View {
    @State var presentDeleteDialog = false
    @ObservedObject var connectionDetailViewModel : ConnectionDetailViewModel
    @State var addAnniversarySheet = false
    var body: some View {
        VStack(spacing: 0){
            HStack{
                VStack(spacing: 3){
                    profileImage(url: connectionDetailViewModel.user1.profilePictureURL)
                    
                    Text(connectionDetailViewModel.user1.userName)
                        .fontWeight(.semibold)
                    Button{
                        
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
                    
                VStack(spacing: 3){
                    profileImage(url: connectionDetailViewModel.user2.profilePictureURL)
                    Text(connectionDetailViewModel.user2.userName)
                        .fontWeight(.semibold)
                    
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
                        .padding(.vertical)
                        
                }
            }
            
            Spacer()
            
        }
        .sheet(isPresented: $addAnniversarySheet){
            NewAnniSheetView()
        }
        .padding()
        .toolbar{
            myToolBarContent()
                
        }
    }
    
    func profileImage(url: URL?) -> some View{
        KFImage(url)
            .placeholder{Image(systemName: "person.fill")}
            .resizable()
            .scaledToFill()
            
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay{
                Circle().stroke(.black, lineWidth: 2)
            }
            .padding(.horizontal)
        
    }
    
    @ToolbarContentBuilder
    func myToolBarContent() -> some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing){
            Menu{
                Button(role: .destructive){
                    presentDeleteDialog = true
                    
                }label: {
                    Label("Delete Connection", systemImage: "minus.circle")
                    
                }
                .confirmationDialog("Deleting connection is permanent. Do you want to delete?",
                                    isPresented: $presentDeleteDialog, titleVisibility: .visible) {
                    Button(role: .destructive){
                        
                    }label: {
                        Text("Delete")
                    }
                    Button("Cancel", role: .cancel, action: { })
                }
            }label: {
                Image(systemName: "ellipsis")
                    .resizable()
                    .scaledToFit()
                    .controlSize(.extraLarge)
            }
            .transition(.opacity)
            
        }
    }
}

#Preview {
    NavigationStack{
        ConnectionDetailView(connectionDetailViewModel: ConnectionDetailViewModel(connectionID: "EiS0k2IJ94qdBccPBk3k"))
    }.tint(.black)
}
