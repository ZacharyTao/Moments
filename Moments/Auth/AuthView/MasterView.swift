//
// AuthenticatedView.swift
//
// Created by Zachary Tao on 11/10/24.


import SwiftUI
import AuthenticationServices

struct MasterView: View {
    @State private var authManager = AuthManager()

    var body: some View {
        Group {
            switch authManager.authenticationState {

            case .unauthenticated:
                LoginView()
                    .environment(authManager)

            case .authenticated:
                HomeView()
                    .environment(authManager)
                    .transition(.asymmetric(insertion: .scale, removal: .identity))
            }
        }
        .animation(.default, value: authManager.authenticationState)
        .onReceive(NotificationCenter.default.publisher(for: ASAuthorizationAppleIDProvider.credentialRevokedNotification)) { event in
            authManager.signOut()
            if let userInfo = event.userInfo, let info = userInfo["info"] {
                print(info)
            }
        }
    }
}
