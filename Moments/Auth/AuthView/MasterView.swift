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
                    .onReceive(NotificationCenter.default.publisher(for: ASAuthorizationAppleIDProvider.credentialRevokedNotification)) { event in
                        authManager.signOut()
                        if let userInfo = event.userInfo, let info = userInfo["info"] {
                            print(info)
                        }
                    }
                    .transition(.asymmetric(insertion: .scale, removal: .identity)) // Slide transition for authentication view
            }
        }.animation(.default, value: authManager.authenticationState)
    }
}
