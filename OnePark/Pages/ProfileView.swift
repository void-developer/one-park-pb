//
//  ProfileView.swift
//  ProfileView
//
//  Created by Leonardo Angeli on 20/08/21.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct ProfileView: View {
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack {
                    
                    LinearGradientCard(colors: [Color("light-purple")], shadowColor: Color("gradient1"), rotationAngle: 10, forEverAnimated: false, width: 300, height: geometry.size.height + 30, shadowRadius: 4)
                        .offset(x: geometry.frame(in: .global).minX - 280)
                    
                    LinearGradientCard(colors: [Color("light-purple")], shadowColor: Color("gradient1"), rotationAngle: 1, forEverAnimated: false, width: 300, height: geometry.size.height + 100, shadowRadius: 4)
                        .offset(x: geometry.frame(in: .global).minX + 310)
                        .opacity(1)
                    
                    ScrollView {
                        ProfileMainContainerView(geometry: geometry)
                    }
                }
            }
            .navigationBarTitle("Profile")
            .navigationBarHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("background1"))
            .edgesIgnoringSafeArea(.all)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .preferredColorScheme(.light)
            .environmentObject(UserViewModel(User(personalInfo: testUser)))
            .environmentObject(ParkViewModel())
    }
}

struct WierdShit: View {
    
    @ObservedObject var parkStore: ParkViewModel
    
    var body: some View {
        VStack {
            
            Image(uiImage: UIImage(imageLiteralResourceName: "trophy"))
            
            
            Text("Driving Towards Users")
            ForEach(parkStore.drivingTowardsUsers.indices, id: \.self) { index in // loop
                
                let value = parkStore.drivingTowardsUsers[index]
                Text("\(value.username ) -> (latitude: \(value.distanceToDestination ?? 0), longitude: \(value.timeToDestination ?? 0)")
                
                
            }
        }
    }
}

struct ProfileMainContainerView: View {
    
    @EnvironmentObject private var userViewModel: UserViewModel
    
    @EnvironmentObject private var parkStore: ParkViewModel
    
    func signOut() {
        print("The current user logged in email is \(Auth.auth().currentUser?.email ?? "Hello")")
        try? Auth.auth().signOut()
        
        userViewModel.signedIn = false
    }
    
    var geometry: GeometryProxy
    var body: some View {
        VStack(spacing: 40) {
            
            ProfileHeader(geometry: geometry)
            
            VStack(spacing: 7) {
                ProfileNavigationItem(itemText: "Personal Info", destination: AnyView(PersonalInfoDataView()))
                
                Divider()
                
                ProfileNavigationItem(itemText: "Notifications", destination: AnyView(Text("Notifications")))
                
                Divider()
                
                ProfileNavigationItem(itemText: "Security", destination: AnyView(Text("Security")))
            }
            .padding(.horizontal, 15)
            .frame(maxWidth: geometry.size.width - 30, maxHeight: 120, alignment: .center)
            .blurViewCard(height: 120, width: geometry.size.width - 30)
            
            Spacer()
            Button(action: {
                signOut()
            }) {
                Text("Button")
                    .foregroundColor(.white)
            }
            .frame(width: 150, height: 45)
            .background(Color.blue)
            
            WierdShit(parkStore: parkStore)
            Spacer()
            
            
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
        .padding(.top, 60 + getAdditionalTopPadding(bounds: geometry))
    }
}

struct ProfileHeader: View {
    
    @EnvironmentObject private var userViewModel: UserViewModel
    
    var geometry: GeometryProxy
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 66, height: 66)
            
            VStack(alignment: .leading) {
                Text("Hi,")
                    .font(.system(.title3, design: .rounded))
                Text(userViewModel.user.personalInfo.username)
                    .bold()
                    .font(.system(size: geometry.size.width/13, design: .rounded))
            }
        }
        .frame(maxHeight: 100, alignment: .leading)
        .blurViewCard(height: 100, width: geometry.size.width - 30)
        .padding(.horizontal)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal)
    }
}

struct ProfileNavigationItem: View {
    
    var itemText: String
    
    var destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Text(itemText)
                    .font(.system(.body, design: .rounded))
                    .foregroundColor(Color.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
            }
        }
    }
}
