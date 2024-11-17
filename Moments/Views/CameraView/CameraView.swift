//
//  ContentView.swift
//  SwiftCamera
//
//  Created by Rolando Rodriguez on 10/15/20.
//

import SwiftUI
import Combine
import AVFoundation

struct CameraView: View {
    @EnvironmentObject var model : CameraModel
    @State var showSend:Bool = false
    @Binding var path: NavigationPath
    @State var currentZoomFactor: CGFloat = 1.0
    @State var lastZoomFacter: CGFloat = 1.0
    
    var body: some View {
        GeometryReader{geometry in
            VStack{
                
                HStack {
                    Button{
                        path.removeLast()
                    }label:{
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                    }
                    .padding(.bottom, 19)
                    
                    Spacer()
                    
                }
                
                CameraPreview(session: model.session)
                    .gesture(
                        MagnificationGesture()
                            .onChanged({ val in
                                    let delta = val / lastZoomFacter
                                if currentZoomFactor * delta < 5{
                                    currentZoomFactor *= delta
                                    model.zoom(with: currentZoomFactor)
                                    lastZoomFacter = val
                                }
                                
                            })
                            .onEnded{ val in
                                lastZoomFacter = 1.0
                            }
                    )
                    .onAppear {
                        model.configure()
                    }
                    .scaledToFill()
                    .frame(width: geometry.size.width * 0.95, height: geometry.size.width * 4.2 / 3)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .alert(isPresented: $model.showAlertError, content: {
                        Alert(title: Text(model.alertError.title), message: Text(model.alertError.message), dismissButton: .default(Text(model.alertError.primaryButtonTitle), action: {
                            model.alertError.primaryAction?()
                        }))
                    })
                
                HStack {
                    flashButton
                    Spacer()
                    captureButton
                    Spacer()
                    flipCameraButton
                }.padding(.horizontal, 65)
                
            }
            .padding(.horizontal, 5)
        }
        .navigationBarBackButtonHidden()
        .background(Color.mainColor1)
        
    }
    
    var captureButton: some View {
        Button {
            model.capturePhoto()
            showSend.toggle()
            path.append(CurrentView.photoPreviewView)
        } label: {
            Circle()
                .foregroundColor(.mainColor1)
                .frame(width: 80, height: 80)
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.8), lineWidth: 5)
                        .frame(width: 65, height: 65, alignment: .center)
                )
        }
    }
    
    var capturedPhotoThumbnail: some View {
        Group {
            if model.photo != nil {
                Image(uiImage: model.photo.image!)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 60, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                
            } else {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 60, height: 60, alignment: .center)
                    .foregroundColor(.black)
            }
        }
    }
    
    var flipCameraButton: some View {
        Button {
            model.flipCamera()
        } label: {
            Image(systemName: "camera.rotate.fill")
                .foregroundColor(.black)
                .font(.title)
        }
    }
    
    var flashButton: some View{
        Button {
            model.switchFlash()
        } label: {
            Image(systemName: model.isFlashOn ? "bolt.fill" : "bolt.slash.fill")
                .font(.largeTitle)
        } .accentColor(model.isFlashOn ? .yellow : .black)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        @State var path = NavigationPath()
        NavigationStack{
            CameraView(path: $path)
                .environmentObject(CameraModel())
        }
    }
}
