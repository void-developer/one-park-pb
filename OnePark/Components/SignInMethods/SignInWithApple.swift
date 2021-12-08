//
//  SignInWithApple.swift
//  SignInWithApple
//
//  Created by Leonardo Angeli on 19/08/21.
//

import SwiftUI
import AuthenticationServices

struct AppleUser: Codable {
    let userId: String
    let firstName: String
    let lastName: String
    let email: String
    
    init?(credentials: ASAuthorizationAppleIDCredential) {
        guard
            let firstName = credentials.fullName?.givenName,
            let lastName = credentials.fullName?.familyName,
            let email = credentials.email
        else {return nil}
        
        self.userId = credentials.user
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}

struct SignInWithApple: View {
    
    var height: CGFloat = 45
    var width: CGFloat = 150
    
    var body: some View {
//        ZStack {
//
//            RoundedRectangle(cornerRadius: 10, style: .continuous)
//
//            Image("apple-logo")
//                .resizable()
//
//            SignInWithAppleButton(
//                .signIn,
//                onRequest: configure,
//                onCompletion: handle
//            )
//            .frame(width: size, height: size)
//            .opacity(0.001)
//            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//        }
//        .frame(width: size, height: size)
        
        SignInWithAppleButton(
            .signIn,
            onRequest: configure,
            onCompletion: handle
        )
        .frame(width: width, height: height)
    }
    
    func configure(_ request: ASAuthorizationAppleIDRequest) {
        request.requestedScopes = [.fullName, .email]
        request.nonce = randomNonceString()
        
    }
    
    func handle(_ authResult: Result<ASAuthorization, Error>) {
        switch authResult {
        case .success(let auth):
            print(auth)
            switch auth.credential {
            case let appleIdCredentials as ASAuthorizationAppleIDCredential:
                if let appleUser = AppleUser(credentials: appleIdCredentials),
                   let appleUserData = try? JSONEncoder().encode(appleUser) {
                    UserDefaults.standard.setValue(appleUserData, forKey: appleUser.userId)
                    
                    print("Saved apple user ", appleUser)
                }
            default:
                print("There was an unexpeted error")
            }
        case .failure(let error):
            print(error)
        }
    }
}

struct SignInWithApple_Previews: PreviewProvider {
    static var previews: some View {
        SignInWithApple()
    }
}
