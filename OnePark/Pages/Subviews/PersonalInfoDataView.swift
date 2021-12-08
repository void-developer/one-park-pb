//
//  PersonalInfoView.swift
//  PersonalInfoView
//
//  Created by Leonardo Angeli on 01/09/21.
//

import SwiftUI

struct PersonalInfoDataView: View {
    
    @EnvironmentObject private var userViewModel: UserViewModel
    
    var body: some View {
        GeometryReader { geometry in
            
            ScrollView {
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    PastelTextField(label: "Full Name", text: Binding(
                        get: { return "\(userViewModel.user.personalInfo.firstName) \(userViewModel.user.personalInfo.lastName)"},
                        set: { _ in print("You cannot change your name for now woaaah")}))
                    
                    PastelTextField(label: "Email", text: $userViewModel.user.personalInfo.email)
                    PastelTextField(label: "Phone Number", text: $userViewModel.user.personalInfo.phoneNumber)
                    //PastelTextField(label: "DOB", text: $userViewModel.userData.dob)
                    //PastelTextField(label: "Email", text: $userViewModel.userData.email)
                    
                }
                .padding(.horizontal, 5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: geometry.size.width - 40, maxHeight: .infinity)
            .padding(.horizontal, 20)
        }
        .navigationBarTitle("Personal Info")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PersonalInfoDataView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalInfoDataView()
            .environmentObject(UserViewModel(User(personalInfo: testUser)))
    }
}

struct PastelTextField: View {
    
    var label: String? = nil
    
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            
            if let label = label {
                Text(label)
                    .font(.system(.body))
                    .padding(.leading, 10)
            }
            
            TextField("Name", text: $text)
                .padding(.leading, 10)
                .frame(height: 50)
                .background(FieldCard())
            
        }
    }
}
