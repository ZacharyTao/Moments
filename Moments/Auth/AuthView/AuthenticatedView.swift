//
// AuthenticatedView.swift
//

import SwiftUI
import AuthenticationServices

extension AuthenticatedView where Unauthenticated == EmptyView {
    init(@ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = nil
        self.content = content
    }
}

struct AuthenticatedView<Content, Unauthenticated>: View where Content: View, Unauthenticated: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    @State private var presentingLoginScreen = false
    @State private var presentingProfileScreen = false
    
    var unauthenticated: Unauthenticated?
    @ViewBuilder var content: () -> Content
    
    public init(
        unauthenticated: Unauthenticated?,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.unauthenticated = unauthenticated
        self.content = content
    }
    
    public init(@ViewBuilder unauthenticated: @escaping () -> Unauthenticated, @ViewBuilder content: @escaping () -> Content) {
        self.unauthenticated = unauthenticated()
        self.content = content
    }
    
    
    var body: some View {
        Group{
            switch viewModel.authenticationState {
                
            case .checking:
                ProgressView()
                
            case .unauthenticated, .authenticating:
                VStack {
                    AuthenticationView()
                        .environmentObject(viewModel)
                }
                .onAppear(){viewModel.reset()}
                .transition(.scale)
                
            case .authenticated:
                content()
                    .environmentObject(viewModel)
                    .onReceive(NotificationCenter.default.publisher(for: ASAuthorizationAppleIDProvider.credentialRevokedNotification)) { event in
                        viewModel.signOut()
                        if let userInfo = event.userInfo, let info = userInfo["info"] {
                            print(info)
                        }
                    }
                    .transition(.asymmetric(insertion: .scale, removal: .identity)) // Slide transition for authentication view
                
            }
        }.animation(.default, value: viewModel.authenticationState) 
    }
}

struct AuthenticatedView_Previews: PreviewProvider {
    static var previews: some View {
        AuthenticatedView {
            Text("You're signed in.")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(.yellow)
        }
    }
}
