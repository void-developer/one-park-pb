//
//  RegisterAltView.swift
//  RegisterAltView
//
//  Created by Leonardo Angeli on 27/08/21.
//

import SwiftUI

//
//  RegisterView.swift
//  OnePark
//
//  Created by Leonardo on 18/08/21.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct RegisterAltView: View {
    
    @ObservedObject var userStore: UserViewModel
    
    @Binding var showRegistration: Bool
    
    @State private var password: String = ""
    @State private var retypePassword: String = ""
    
    @Binding var isLoading: Bool
    
    @State private var dob: Date = Date()
    
    @State private var isRegistrationCorrect = false
    
    @State private var isPasswordCorrect: Bool = false
    @State private var isPersonalInfoCorrect: Bool = false
    
    @State private var fieldErrors: String = ""
    @State private var showErrorsCard: Bool = false
    
    @StateObject private var passwordValidation: PasswordValidation = PasswordValidation()
    
    func checkRegistrationValidationStatus() -> Bool {
        fieldErrors = ""
        isPersonalInfoCorrect = fieldErrors.isEmpty
        
        if let errors = userStore.user.personalInfo.validatePersonalInfo() {
            isPersonalInfoCorrect = false
            fieldErrors = errors
        } else {
            isPersonalInfoCorrect = true
        }
        
        if let errors = validatePassword(password: password, retypePassword: retypePassword, passwordValidation: passwordValidation) {
            isPasswordCorrect = false
            fieldErrors = errors
        } else {
            isPasswordCorrect = true
        }
        
        showErrorsCard = !fieldErrors.isEmpty
        isRegistrationCorrect = isPasswordCorrect && isPersonalInfoCorrect
        return isRegistrationCorrect
    }

    
    var body: some View {
        
        GeometryReader { geometry in
            
            let textFieldDefaultWidth = geometry.size.width - 80
            

            ZStack {
                
                VStack(spacing: 20) {
                    Text("Register")
                        .font(.system(size: 45, weight: .bold, design: .rounded))
                        .foregroundColor(Color.black)
                        
                        ScrollView {
                            RegisterAltFieldsView(userStore: userStore, textFieldDefaultWidth: textFieldDefaultWidth, dob: $dob, password: $password, retypePassword: $retypePassword, geometry: geometry, isRegistrationCorrect: $isRegistrationCorrect, isPasswordCorrect: $isPasswordCorrect, isPersonalInfoCorrect: $isPersonalInfoCorrect, fieldsError: $fieldErrors, passwordValidation: passwordValidation)
                        }

                    RegisterButton(geometry: geometry, userStore: userStore, password: $password, showRegistration: $showRegistration, isLoading: $isLoading, dob: $dob, fieldsError: $fieldErrors, checkRegistrationStatus: checkRegistrationValidationStatus)
                }
                .padding(.top, 20)
                
                VStack {
                    Spacer()
                    
                    //TODO: Add nsError support!
                    SideNotesCard(height: 130, header: "Errors", content: $fieldErrors, show: $showErrorsCard, nsError: .constant(nil))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
              
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onChange(of: fieldErrors) { newValue in
            showErrorsCard = !fieldErrors.isEmpty
        }
    }
}

struct RegisterAltView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterAltView(userStore: UserViewModel(), showRegistration: .constant(true), isLoading: .constant(false))
    }
}

struct RegisterTextFieldAlt: View {
    
    @Binding var textFieldValue: String
    var placeholder: String
    var label: String
    var horizontalPadding: CGFloat = 40
    
    var maxWidth: CGFloat
    
    var secureField: Bool = false
    
    var contentType: UITextContentType?
     
    var systemIcon: String?
    
    var autoCapitalization: UITextAutocapitalizationType = .none
    
    var onCommit: () -> Void = {}
    
    var body: some View {
            HStack {
                if let systemIcon = systemIcon {
                    Image(systemName: systemIcon)
                        .font(.system(size: 22))
                        .foregroundColor(Color("gradient1"))
                }
                      
                if secureField {
                    SecureField(placeholder, text: $textFieldValue, onCommit: onCommit)
                        .textContentType(contentType ?? nil)
                        .foregroundColor(Color("gradient2"))
                        
                } else {
                    TextField(placeholder, text: $textFieldValue, onCommit: onCommit)
                        .textContentType(contentType ?? nil)
                        .autocapitalization(.none)
                        .foregroundColor(Color("gradient2"))
                }
            }
            .foregroundColor(Color("gradient2"))
            .frame(maxWidth: maxWidth, maxHeight: 40)
            .padding(.horizontal, 10)
    }
}

struct RegisterAltFieldsView: View {
    
    @ObservedObject var userStore: UserViewModel
    
    var textFieldDefaultWidth: CGFloat
    @State var _dobStateString: String = ""
    
    @State var showDOBDatePicker: Bool = false
    
    @Binding var dob: Date
    
    @Binding var password: String
    @Binding var retypePassword: String
    
    var geometry: GeometryProxy
    
    @Binding var isRegistrationCorrect: Bool
    
    @Binding var isPasswordCorrect: Bool
    @Binding var isPersonalInfoCorrect: Bool
    
    @Binding var fieldsError: String
    
    @ObservedObject var passwordValidation: PasswordValidation
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            PersonalAltInfoView(geometry: geometry, textFieldDefaultWidth: textFieldDefaultWidth, userStore: userStore, isPersonalInfoCorrect: $isPersonalInfoCorrect, fieldsError: $fieldsError)
            
            PasswordAltFields(geometry: geometry, password: $password, retypePassword: $retypePassword, textFieldDefaultWidth: textFieldDefaultWidth, passwordValidation: passwordValidation, isPasswordCorrect: $isPasswordCorrect, fieldsError: $fieldsError)

        }
        .padding(.bottom, 40)
    }
}



struct PasswordAltFields: View {
    
    var geometry: GeometryProxy
    
    @Binding var password: String
    @Binding var retypePassword: String
    
    var textFieldDefaultWidth: CGFloat
    
    @ObservedObject var passwordValidation: PasswordValidation
    @State var strength: String = ""
    
    @Binding var isPasswordCorrect: Bool
    @State var checkedPassword: Bool = false
    @Binding var fieldsError: String
    
    func validatePassword() {
        fieldsError = ""
        if let error = OnePark.validatePassword(password: password, retypePassword: retypePassword, passwordValidation: passwordValidation) {
            isPasswordCorrect = false
            fieldsError = error
        } else {
            isPasswordCorrect = true
        }
        checkedPassword = true
    }
    
    func checkPasswordValidation() {
        let _ = PasswordUtility.checkValidationWithUniqueCharacter(pass: password, rules: PasswordRules.passwordRule, minLength: PasswordRules.minPasswordLength, maxLength: PasswordRules.maxPasswordLength, isUniqueCharRequired: false, passwordValidation: passwordValidation)
        print("Password validation string is now \(passwordValidation.strength)")
        strength = passwordValidation.strength.rawValue
    }
    
    var body: some View {
        
        ZStack {
            
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundColor(Color("light-purple"))
                .shadow(color: Color.black.opacity(0.4), radius: 3, x: 3, y: 3)
            
            VStack {
                RegisterTextFieldAlt(textFieldValue: $password, placeholder: "Password", label: "Password", maxWidth: textFieldDefaultWidth, secureField: true, contentType: .newPassword, systemIcon: "lock.fill", onCommit: validatePassword)
                    
                
                RegisterTextFieldAlt(textFieldValue: $retypePassword, placeholder: "Retype your password", label: "Retype Password", maxWidth: textFieldDefaultWidth, secureField: true, contentType: .newPassword, systemIcon: "lock.open.fill", onCommit: validatePassword)
            }
        }
        .frame(maxWidth: geometry.size.width-60)
        .frame(height: (40+10)*2)
        .progressShapeOverlay(
            progress:  checkedPassword && !isPasswordCorrect ? 1 : passwordValidation.progressView.percentage,
            shapeType: .roundedRectangle,
            colors: [checkedPassword && !isPasswordCorrect ? Color.red : Color.init(hex: passwordValidation.progressView.color)],
            rotationEffectAngle: 180, rotation3DEffectAngle: 180)
        .onChange(of: password) { newValue in
            checkPasswordValidation()
            checkedPassword = false
        }
        .onChange(of: retypePassword) { newValue in
            checkedPassword = false
        }
    }
}

struct PersonalAltInfoView: View {
    
    var geometry: GeometryProxy
    var textFieldDefaultWidth: CGFloat
    
    @ObservedObject var userStore: UserViewModel
    
    @Binding var isPersonalInfoCorrect: Bool
    @State var checkedPersonalInfo: Bool = false
    @Binding var fieldsError: String
    
    func validatePersonalInfo() {
        fieldsError = ""
        if let error = userStore.user.personalInfo.validatePersonalInfo() {
            isPersonalInfoCorrect = false
            fieldsError = error
        } else {
            isPersonalInfoCorrect = true
        }
        checkedPersonalInfo = true
    }
    
    var body: some View {
        ZStack {
            
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .foregroundColor(Color("light-purple"))
                .shadow(color: Color.black.opacity(0.4), radius: 3, x: 3, y: 3)
            
            VStack (spacing: 5){
                HStack(alignment: .center) {
                    RegisterTextField(textFieldValue: $userStore.user.personalInfo.firstName, placeholder: "Jhon", label: "First Name", horizontalPadding: 0, maxWidth: textFieldDefaultWidth, contentType: .givenName, autoCapitalization: .words, onCommit: validatePersonalInfo)
                    
                    RegisterTextField(textFieldValue: $userStore.user.personalInfo.lastName, placeholder: "Appleseed", label: "Last Name", horizontalPadding: 0, maxWidth: textFieldDefaultWidth, contentType: .familyName, autoCapitalization: .words, onCommit: validatePersonalInfo)
                }
                .padding(.horizontal, 40)
                
            
                
                RegisterTextField(textFieldValue: $userStore.user.personalInfo.email, placeholder: "jhon.appleseed@icloud.com", label: "Email", maxWidth: textFieldDefaultWidth, contentType: .emailAddress, systemIcon: "envelope.fill", onCommit: validatePersonalInfo)
                
                
                RegisterTextField(textFieldValue: $userStore.user.personalInfo.username, placeholder: "jhonnyTheApple", label: "Username", maxWidth: textFieldDefaultWidth, contentType: .username, systemIcon: "person.fill", onCommit: validatePersonalInfo)
                
                RegisterTextField(textFieldValue: $userStore.user.personalInfo.phoneNumber, placeholder: "+1 3009992121", label: "Phone Number", maxWidth: textFieldDefaultWidth, contentType: .telephoneNumber, systemIcon: "phone.fill", onCommit: validatePersonalInfo)
            }
        }
        .frame(maxWidth: geometry.size.width-60)
        .frame(height: (40+10)*4)
        .progressShapeOverlay(
            progress:  checkedPersonalInfo ? 1 : 0,
            shapeType: .roundedRectangle,
            colors: isPersonalInfoCorrect ? [Color(hex: 0x8BC34A)] : [Color.red],
            rotationEffectAngle: 180, rotation3DEffectAngle: 180)
        .padding(.horizontal, 30)
    }
}


struct RegisterButton: View {
    
    @GestureState var tap: Bool = false
    var geometry: GeometryProxy
    @ObservedObject var userStore: UserViewModel
    
    @Binding var password: String
    @Binding var showRegistration: Bool
    @Binding var isLoading: Bool
    
    @Binding var dob: Date
    
    @Binding var fieldsError: String
    
    var checkRegistrationStatus: () -> Bool
    
    func register() {
        if !checkRegistrationStatus() {
            return
        }
        
        isLoading = true
        print("Registering new user \(userStore.user.personalInfo.username)")
        
        
        userStore.user.personalInfo.email = userStore.user.personalInfo.email.lowercased()
        userStore.user.personalInfo.setDOB(dob: dob)
        
        //Auth.auth().currentUser.set
        Auth.auth().createUser(withEmail: userStore.user.personalInfo.email, password: password) { authResult, error in
            if let error = error {
                print("There has been an error with registering the user \(error)")
                fieldsError = error.localizedDescription
                isLoading = false
            } else if let currentUser = Auth.auth().currentUser?.createProfileChangeRequest() {
                currentUser.displayName = userStore.user.personalInfo.username
                currentUser.commitChanges { error in
                    if let error = error {
                        print("There has been an error with registering the user \(error)")
                        fieldsError = error.localizedDescription
                        isLoading = false
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            userStore.save()
                            showRegistration = false
                            //print("Show registration is now \(showRegistration)")
                            isLoading = false
                        }
                    }
                }
            }
        }
        
    }
    
    var body: some View {
        ZStack {
            Text("P")
                .font(.system(size: geometry.size.width/7, weight: .heavy, design: .rounded))
                .foregroundColor(Color("gradient3"))
        }
        .circleProgressButton(baseButtonSize: geometry.size.width/10, buttonMinSize: 80, buttonMaxSize: 100, tap: tap)
        .gesture(
            LongPressGesture(minimumDuration: 0.2, maximumDistance: 50)
                .updating($tap, body: { currentState, gestureState, transaction in
                    gestureState = currentState
                    impact(intensity: .medium)
                })
                .onEnded({ value in
                    register()
                })
        )
    }
}

func validatePassword(password: String, retypePassword: String, passwordValidation: PasswordValidation) -> String? {
    if password.isEmpty {
        return "Please add a valid password"
    } else if !passwordValidation.allRequirementDone {
        return passwordValidation.text
    } else if password != retypePassword {
        return "The password and the retyped passwords do not match"
    }
    return nil
}


struct RegisterTextField: View {
    
    @Binding var textFieldValue: String
    var placeholder: String
    var label: String
    var horizontalPadding: CGFloat = 40
    
    var maxWidth: CGFloat
    
    var secureField: Bool = false
    
    var contentType: UITextContentType?
    
    var systemIcon: String?
    
    var autoCapitalization: UITextAutocapitalizationType = .none
    
    var onCommit: () -> Void = {}
    
    var body: some View {
        HStack {
            if let systemIcon = systemIcon {
                Image(systemName: systemIcon)
                    .font(.system(size: 22))
                    .foregroundColor(Color("gradient1"))
            }
            
            if secureField {
                SecureField(placeholder, text: $textFieldValue, onCommit: onCommit)
                    .textContentType(contentType ?? nil)
                
            } else {
                TextField(placeholder, text: $textFieldValue, onCommit: onCommit)
                    .textContentType(contentType ?? nil)
                    .autocapitalization(.none)
            }
        }
        .frame(maxWidth: maxWidth, maxHeight: 40)
        .padding(.horizontal, 10)
    }
}
