//
//  AppView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 4/14/24.
//

import SwiftUI

struct AppView: View {
    @StateObject var userDataManager = UserDataManager()
    @StateObject var cameraModel = CameraModel()
    @State var path = NavigationPath()
    @State var currentConnectionId = ""
    
    var body: some View {
        NavigationStack(path: $path){
            MainView(path: $path, currentConnectionId: $currentConnectionId)
                .onAppear{currentConnectionId = ""}
                .navigationDestination(for: CurrentView.self){ viewEnum in
                    switch viewEnum{
                    case .cameraView:
                        CameraView(path: $path)
                            .environmentObject(cameraModel)
                            .onAppear{
                                cameraModel.photo = nil
                            }
                    case .photoPreviewView:
                        PhotoPreviewView(path: $path, connectionId: currentConnectionId)
                            .environmentObject(cameraModel)
                            .environmentObject(userDataManager)
                    case .userProfileView:
                        UserProfileView(path: $path)
                            .environmentObject(userDataManager)
                    case .editProfileView:
                        EditProfileView(path: $path)
                            .environmentObject(userDataManager)
                    case .connectionView:
                        ConnectingView(path: $path)
                            .environmentObject(userDataManager)
                    default:
                        ProgressView()
                    }
                    
                }
                .navigationDestination(for: String.self){ id in
                    PhotoChatView(photosChatViewModel: PhotoChatViewModel(connectionID: id), connectionDetailViewModel: ConnectionDetailViewModel(connectionID: id), path: $path)
                            .onAppear{
                                cameraModel.resetSession()
                                cameraModel.session.stopRunning()
                            }
                }
            
        }.tint(.black)
    }
}

#Preview {
    AppView()
}

enum CurrentView{
    case chatView
    case cameraView
    case photoPreviewView
    case userProfileView
    case editProfileView
    case connectionView
}


