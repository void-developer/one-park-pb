//
//  MainView.swift
//  MainView
//
//  Created by Leonardo Angeli on 20/08/21.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct MainView: View {
    
    @EnvironmentObject private var userStore: UserViewModel
    @EnvironmentObject private var parkStore: ParkViewModel
    @EnvironmentObject private var notificationStore: NotificationStore
    var body: some View {
        
        //print(parkStore.parkingMode.rawValue)
        VStack {
            if userStore.signedIn {
                TabBarView()
            } else {
                LoginView()
            }
        }
        .onAppear {
            userStore.signedIn = userStore.isSignedIn
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
