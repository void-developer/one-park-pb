//
//  AppleSignInMethod.swift
//  AppleSignInMethod
//
//  Created by Leonardo Angeli on 19/08/21.
//

//import SwiftUI
//import CryptoKit
//import AuthenticationServices
//
//// Unhashed nonce.
//fileprivate var currentNonce: String?
//
//class SignInMethodsController: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
//    
//    var view: View
//    
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return self.view.window!
//    }
//    
//    
//    @available(iOS 13, *)
//    func startSignInWithAppleFlow() {
//        let nonce = randomNonceString()
//        currentNonce = nonce
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//        request.nonce = sha256(nonce)
//
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
//    }
//
//    @available(iOS 13, *)
//    private func sha256(_ input: String) -> String {
//        let inputData = Data(input.utf8)
//        let hashedData = SHA256.hash(data: inputData)
//        let hashString = hashedData.compactMap {
//        return String(format: "%02x", $0)
//        }.joined()
//
//        return hashString
//    }
//    
//}
