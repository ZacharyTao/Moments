//
//  PhotoPreviewView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 3/27/24.
//

import SwiftUI
import CoreLocation

struct PhotoPreviewView: View {
    @EnvironmentObject var model : CameraModel
    @EnvironmentObject var userDataManager: UserDataManager
    
    @State private var locationString: String = "    "
    @State private var caption: String = ""
    @Binding  var path: NavigationPath
    @ObservedObject var locationDataManager = LocationDataManager()
    var connectionId: String
    
    var body: some View {
        GeometryReader{geometry in
                VStack{
                    header
                    Spacer()
                    if let imageData = model.photo?.originalData,
                       let uiImage = UIImage(data: imageData),
                       let _ = model.photo?.locationString
                    {
                        HStack{
                            dateView
                            Text(" · ")
                            locationView()
                        }
                        .padding(.horizontal)
                        .fontWeight(.medium)
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .shadow(radius: 2)
                            .transition(.opacity)
                        
                        TextField("Add a caption...", text: $caption)
                            .multilineTextAlignment(.center)
                            .font(.body)
                            .ignoresSafeArea(.keyboard, edges: .bottom)
                        
                        
                    }else{
                        ProgressView()
                    }
                    
                    Spacer()
                    Spacer()
                }.padding(.horizontal, 5)
                .animation(.easeOut, value: model.photo?.originalData)
            
            .navigationBarBackButtonHidden()
            .background(Color.mainColor1)
            
        }.onAppear{
            if locationDataManager.locationManager.authorizationStatus == .authorizedWhenInUse{
                if let location = locationDataManager.locationManager.location{
                    getPlacemark(for: location) { placemark in
                        if let placemark = placemark, let city = placemark.locality, let district = placemark.subLocality {
                            self.locationString = "\(district), \(city)"
                            model.photo?.locationString = locationString
                        } else {
                            self.locationString = ""
                        }
                    }
                }
            }else{
                self.locationString = ""
                model.photo?.locationString = locationString

            }
            
        }
    }
    
    var header: some View{
        HStack {
            Button{
                path.removeLast(2)
            }label:{
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
            }
            .padding(.bottom, 19)
            
            Spacer()
            Button{
                model.photo.caption = caption
                userDataManager.uploadMessagetoConnection(connectionId: connectionId, photo: model.photo)
                path.removeLast(2)
            }label: {
                HStack{
                    Spacer()
                    
                    Text("Send")
                        .foregroundColor(.black)
                        .font (.system(size: 30, weight: .heavy))
                    Image(systemName: "chevron.forward")
                        .resizable()
                        .scaledToFit()
                        .font(Font.system(size: 20, weight: .bold))
                        .frame(width: 20, height: 20)
                        .foregroundColor(.black)
                }
            }
            
        }
    }
    
    var dateView : some View{
        Text(formatDate(Date()))
            .onAppear{
                model.photo?.timestamp = Date()
            }
        
    }
    
    @ViewBuilder
    func locationView() -> some View {
        switch locationDataManager.locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            
            Text(locationString)
                .onAppear {
                    if let location = locationDataManager.locationManager.location{
                        getPlacemark(for: location) { placemark in
                            if let placemark = placemark, let city = placemark.locality {
                                
                                if let district = placemark.subLocality{
                                    self.locationString = "\(district), \(city)"
                                }else{
                                    self.locationString = "\(city)"
                                }
                                model.photo?.locationString = locationString
                                model.photo?.location = location
                            } else {
                                self.locationString = ""
                                print("Error getting location \(String(describing: placemark))")
                            }
                        }
                    }
                    
                }
            
            
        case .restricted, .denied:
            Text(locationString)
        case .notDetermined:
            Text(locationString)
        default:
            ProgressView()
        }
        
    }
    
    private func getPlacemark(for location: CLLocation, completion: @escaping (CLPlacemark?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard error == nil else {
                print("Error in reverseGeocodeLocation: \(error!.localizedDescription)")
                completion(nil)
                return
            }
            
            completion(placemarks?.first)
        }
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "     " }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter.string(from: date)
    }
}

#Preview {
    struct preview: View {
        @State var path = NavigationPath()
        var body: some View {
            NavigationStack{
                PhotoPreviewView(path: $path, connectionId: "error").environmentObject(CameraModel())
                    .environmentObject(UserDataManager())
            }
        }
    }
    return preview()
}

