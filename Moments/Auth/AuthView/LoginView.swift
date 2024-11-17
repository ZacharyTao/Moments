//
// LoginView.swift
//
// Created by Zachary Tao on 11/10/24.

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(AuthManager.self) var authManager

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Welcome to Moments")
                .font(.title)
                .fontWeight(.bold)

            Spacer()

            AppleSignInButton

            GoogleSignInButton

            Spacer()
        }.padding()
    }

    var AppleSignInButton: some View{
        SignInWithAppleButton(.signIn) { request in
            authManager.handleSignInWithAppleRequest(request)
        } onCompletion: { result in
            authManager.handleSignInWithAppleCompletion(result)
        }
        .signInWithAppleButtonStyle(.black)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .cornerRadius(10)
    }

    var GoogleSignInButton: some View{
        Button {
            Task {
                await authManager.signInWithGoogle()
            }
        } label: {
            HStack(alignment: .center){
                Image("Google")
                Text("Sign in with Google")
            }.padding(0)
            .frame(maxWidth: .infinity)
        }
        .frame(height: 50)
        .foregroundColor(.black)
        .buttonStyle(.bordered)
        .cornerRadius(10)
    }
}

#Preview {
    LoginView()
        .environment(AuthManager())
}
