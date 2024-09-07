//
//  MainView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 4/14/24.
//

import SwiftUI


extension View {
    /// default is placeholder type
    @ViewBuilder
    func redacted(when show: Bool,
                  reason: RedactionReasons = RedactionReasons.placeholder) -> some View {
        redacted(reason: show ? reason : .invalidated)
        
    }
}


struct MainView: View {
    @Binding var path: NavigationPath
    @StateObject var mainViewModel = MainViewModel()
    @Binding var currentConnectionId: String
    
    var body: some View {
        VStack{
            ScrollView{
                LazyVGrid(columns: [GridItem(), GridItem()]){
                    ForEach(mainViewModel.connectionPreviews.sorted(by: {$0.timeStamp ?? Date() > $1.timeStamp ?? Date()}), id: \.self){connection in
                        ZStack{
                            RoundedRectangle(cornerRadius: 15)
                                .foregroundStyle(Color.first)
                                .aspectRatio(2.6/4, contentMode: .fit)
                                .ignoresSafeArea()
                            MainView_ConnectionPreview(connection: connection)
                                .onTapGesture {
                                    currentConnectionId = connection.connectionID
                                    path.append(connection.connectionID)
                                }
                                .padding(7)
                        }
                        .aspectRatio(2.6/4, contentMode: .fit)
                    }
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundStyle(Color.first)
                            .aspectRatio(2.6/4, contentMode: .fit)
                            .ignoresSafeArea()
                        Image(systemName: "plus")
                            .font(.system(size: 70))
                            .fontWeight(.medium)
                            .foregroundStyle(Color.second.opacity(0.85))
                            .padding(40)
                        
                    }.onTapGesture {
                        path.append(CurrentView.connectionView)
                    }
                    
                }
            }.scrollIndicators(.hidden)
                .refreshable {
                    mainViewModel.fetchConnectionPreviews()
                }
                .redacted(when: mainViewModel.isLoading)
        }
        .onAppear{
            mainViewModel.fetchConnectionPreviews()
        }
        .navigationBarTitle(Text(""), displayMode: .inline)
        .padding()
        .toolbar{
            ToolbarItem(placement: .topBarLeading){
                
                Button{
                    path.append(CurrentView.userProfileView)
                }label: {
                    Image(systemName: "line.3.horizontal")
                        .resizable()
                        .scaledToFit()
                        .controlSize(.extraLarge)
                }
                .foregroundStyle(.black)
                .fontWeight(.bold)
            }
            ToolbarItem(placement: .principal){
                Text("Moments")
                    .fontWeight(.bold)
                    .font(.title2)
                    .foregroundStyle(Color.second)
            }
            
        }
        
    }
}

#Preview {
    struct preview : View{
        @State var path = NavigationPath()
        @State var id = ""
        var body: some View{
            NavigationStack{
                MainView(path: $path, currentConnectionId: $id)
                    .environmentObject(UserDataManager())
                    .fontDesign(.rounded)
            }
        }
    }
    return preview()
    
}
