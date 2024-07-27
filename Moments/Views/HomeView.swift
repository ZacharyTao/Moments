//
//  ContentView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 3/23/24.
//

import SwiftUI

struct HomeView: View {
    @StateObject var infoViewModel = SignUpInfoViewModel()

    
    enum homeViewLogic{
        case appView
        case signUpInfo
        case progress
    }
    
    @State var viewLogic: homeViewLogic = .progress
    
    var body: some View {
            
            Group{
                switch viewLogic {
                case .progress:
                    ProgressView()
                case .appView:
                    AppView()
                case .signUpInfo:
                    SignUpInfoView(viewLogic: $viewLogic)
                        .environmentObject(infoViewModel)
                }
            }
            .task{
                let result = await infoViewModel.checkIfMomentsUserExists()
                viewLogic = result ? .appView : .signUpInfo
            }
    }
}

#Preview {
    HomeView()
}
