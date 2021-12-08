//
//  LoginView.swift
//  OnePark
//
//  Created by Leonardo on 16/08/21.
//

import SwiftUI
import Firebase

struct LoginView: View {
    
    @State private  var username: String = ""
    @State private var password: String = ""
    @State private var isFocused: Bool = false

    @State private var isLoading = false

    @EnvironmentObject var user: UserViewModel
    
    @State private var showRegistration: Bool = false
    @State private var showErrorCard: Bool = false
    @State private var loginErrors: String = ""
    
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ZStack {
                    VStack {
                        LoginCard(geometryProxy: geometry)
                        
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                    
                    VStack {

                        LoginInputFields(geometry: geometry, username: $username, password: $password)
                        
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .offset(y: isFocused ? -100 : -20)
                    .animation(.timingCurve(0.2, 0.8, 0.2, 1, duration: 0.8))
                    .onTapGesture {
                        isFocused = false
                        hideKeyboard()
                    }
                    
                    Footer(geometry: geometry, isLoading: $isLoading, username: $username, password: $password, loginErrors: $loginErrors, showErrorCard: $showErrorCard, showRegistration: $showRegistration)
                    
                    VStack {
                        Spacer()
                        
                        //TODO: Add nsError support!
                        SideNotesCard(height: 130, header: "We had trouble Signing you in", content: $loginErrors, show: $showErrorCard, nsError: .constant(nil))
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
            
                }

            }
            .blur(radius: isLoading ? 3 : 0)
            .sheet(isPresented: $showRegistration) {
                RegistrationSheet(user: user, showRegistration: $showRegistration, isLoading: $isLoading)
            }
            
            if isLoading {
                LoadingAnimationView(componentWidth: 200, componentHeight: 200)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(UserViewModel())
            
    }
}

struct LoginCard: View {
    
    var geometryProxy: GeometryProxy
    
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("OnePark")
                    .foregroundColor(Color.white)
                    .font(.system(size: geometryProxy.size.width/5, weight: .bold, design:.rounded))
                
                Text("Park easily, together.")
                    .foregroundColor(Color.white)
                    .font(.system(size: 22, weight: .light, design:.rounded))
            }
            .padding(.horizontal, 10)
            .background(
                ZStack {
                    LinearGradientCard(colors: [Color("gradient1"),Color("gradient2")], shadowColor: Color("gradient3"), rotationAngle: 40)
                    
                    
                    LinearGradientCard(colors: [Color("gradient3"),Color("gradient2")], shadowColor: Color("gradient3"), rotationAngle: 30)
                }
            )
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: 350)
        .animation(.easeInOut)
        .padding(.top, getAdditionalTopPadding(bounds: geometryProxy)/8)
        .edgesIgnoringSafeArea(.all)
    }
}

struct LoginButton: View {
    
    var geometryProxy: GeometryProxy
    @Binding var isLoading: Bool
    
    @Binding var email: String
    @Binding var password: String
    
    @EnvironmentObject var user: UserViewModel
    
    @Binding var loginErrors: String
    @Binding var showErrorCard: Bool
    
    @EnvironmentObject var notificationViewModel: NotificationStore
    
    func login() {
        isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { authResponse, error in

            if error != nil {
                isLoading = false
                loginErrors = error?.localizedDescription ?? "Something went wrong."
                showErrorCard = true
                haptic(type: .error)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isLoading = false
                    haptic(type: .success)
                    user.signedIn = true
                    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound, .carPlay]
                    UNUserNotificationCenter.current().requestAuthorization(
                    options: authOptions,
                    completionHandler: {_, _ in })
                    notificationViewModel.addDeviceToken()
                }
                
            }
        
        }
    }
    
    var body: some View {
        
        let baseButtonSize = geometryProxy.size.width/10
        
        let buttonMinSize: CGFloat = 80
        let buttonMaxSize: CGFloat = 100
    
        ZStack {
            Text("P")
                .font(.system(size: geometryProxy.size.width/7, weight: .heavy, design: .rounded))
                .foregroundColor(Color("gradient3"))
        }
        .frame(width: baseButtonSize, height: baseButtonSize)
        .frame(minWidth: buttonMinSize, maxWidth: buttonMaxSize, minHeight: buttonMinSize, maxHeight: buttonMaxSize)
        .background(
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), Color(#colorLiteral(red: 0.949164331, green: 0.9693112969, blue: 1, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
                
                Circle()
                    .stroke(Color.clear, lineWidth: 10)
                    .shadow(color: Color(#colorLiteral(red: 0.9032872319, green: 0.960066855, blue: 1, alpha: 1)), radius: 3, x: -5, y: -5)
                Circle()
                    .stroke(Color.clear, lineWidth: 10)
                    .shadow(color: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), radius: 3, x: 3, y: 3)
                
            }
        )
        .clipShape(Circle())
        .shadow(color: Color.black.opacity(0.4), radius: 10, x: 5, y: 5)
        .onTapGesture {
            login()
        }
    }
}

struct LoginInputFields: View {
    
    var geometry: GeometryProxy
    
    @Binding var username: String
    @Binding var password: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .frame(height: 60*2)
                .foregroundColor(Color.white)
                .shadow(color: Color.black.opacity(0.4), radius: 10, x: 0, y: 0)
            
            VStack(spacing: 10) {
                HStack {
                    Image(systemName: "person.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color("gradient1"))
                    
                    TextField("Email", text: $username)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                        .disableAutocorrection(true)
                    
                }
                .frame(height: 35)
                .padding(.horizontal, 10)
                
                Divider()
                    .padding(.horizontal, 60)
                
                HStack {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 22))
                        .foregroundColor(Color("gradient1"))
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .autocapitalization(.none)
                    
                }
                .frame(height: 35)
                .padding(.horizontal, 10)
            }
            .frame(height: 60*2)
        }
        .frame(height: 60*2)
        //.frame(maxWidth: geometry.size.width-80)
        .padding(.horizontal, 40)
    }
}

struct Footer: View {
    
    var geometry: GeometryProxy
    @Binding var isLoading: Bool
    @Binding var username: String
    @Binding var password: String
    @Binding var loginErrors: String
    @Binding var showErrorCard: Bool
    @Binding var showRegistration: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            LoginButton(geometryProxy: geometry, isLoading: $isLoading, email: $username, password: $password, loginErrors: $loginErrors, showErrorCard: $showErrorCard)
            
            Button(action: { self.showRegistration.toggle() }) {
                Text("Don't have an account yet? Register here")
                    .font(.system(.caption))
                    .foregroundColor(Color.black)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

struct RegistrationSheet: View {
    
    @ObservedObject var user: UserViewModel
    
    @Binding var showRegistration: Bool
    @Binding var isLoading: Bool
    var body: some View {
        ZStack {
            RegisterAltView(userStore: user, showRegistration: $showRegistration, isLoading: $isLoading)
            
            if isLoading && showRegistration {
                LoadingAnimationView(componentWidth: 200, componentHeight: 200)
            }
        }
    }
}
