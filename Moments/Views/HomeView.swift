//
//  ContentView.swift
//  MomentsV2
//
//  Created by Zachary Tao on 3/23/24.
//

import SwiftUI

struct HomeView: View {
    @State var viewLogic: homeViewLogic = .progress
    @Environment(AuthManager.self) var authManager

    var body: some View {
            Group{
                switch viewLogic {
                case .progress:
                    ProgressView()
                case .appView:
                    AppView()
                case .signUpInfo:
                    SignUpInfoView(viewLogic: $viewLogic)
                }
            }
            .onAppear {
                let result = authManager.isUserFirstTimeLogIn()
                viewLogic = result ? .signUpInfo : .appView
            }
    }

    enum homeViewLogic{
        case appView
        case signUpInfo
        case progress
    }

}

#Preview {
    HomeView()
        .environment(AuthManager())
}
