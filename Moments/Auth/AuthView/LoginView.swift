//
// LoginView.swift
// Favourites
//
// Created by Peter Friese on 08.07.2022
// Copyright © 2022 Google LLC.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import SwiftUI
import Combine
import AuthenticationServices



struct LoginView: View {
    @EnvironmentObject var viewModel: AuthenticationViewModel
    @Environment(\.colorScheme) var colorScheme
    
    
    
    var body: some View {
        VStack {
            Spacer()
            Text("Welcome to Moments")
                .font(.title)
                .fontWeight(.bold)
            Spacer()
            AppleSignInButton.padding(.vertical)
            GoogleSignInButton
            Text(viewModel.errorMessage)
            Spacer()
        }.padding()
    }
    
    var AppleSignInButton: some View{
        SignInWithAppleButton(.signIn) { request in
            viewModel.handleSignInWithAppleRequest(request)
        } onCompletion: { result in
            viewModel.handleSignInWithAppleCompletion(result)
        }
        .signInWithAppleButtonStyle(.black)
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .cornerRadius(10)
    }
    
    var GoogleSignInButton: some View{
        Button(action: signInWithGoogle) {
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
    
    private func signInWithGoogle() {
        Task {
            await viewModel.signInWithGoogle()
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            LoginView()
            LoginView()
                .preferredColorScheme(.dark)
        }
        .environmentObject(AuthenticationViewModel())
    }
}
