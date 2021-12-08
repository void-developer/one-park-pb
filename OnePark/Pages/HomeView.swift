//
//  HomeView.swift
//  OnePark
//
//  Created by Leonardo on 17/08/21.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @Binding var showDrivingTowardsUsers: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                HomeContainerView(geometry: geometry, coins: userViewModel.user.personalInfo.getCoins(), points: userViewModel.user.personalInfo.getPoints(), showDrivingTowardsUsers: $showDrivingTowardsUsers)
                    .background(Color("primary-background"))
//                    .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
                    
            }
            
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.top)
        .onAppear {
            userViewModel.fetch()
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(showDrivingTowardsUsers: .constant(false))
            .preferredColorScheme(.light)
            .environmentObject(UserViewModel())
                .environmentObject(ParkViewModel())
        
    }
}

