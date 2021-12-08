//
//  HomeContainerView.swift
//  HomeContainerView
//
//  Created by Leonardo Angeli on 20/08/21.
//

import SwiftUI
import FirebaseAuth

struct HomeContainerView: View {
    
    var geometry: GeometryProxy
    var coins: Int = 0
    var points: Int = 0
    
    @EnvironmentObject var userViewModel: UserViewModel
    @EnvironmentObject var parkViewModel: ParkViewModel
    
    @State var showFullScreen: Bool = false
    @State var showParkingModeCard: Bool = false
    
    @Binding var showDrivingTowardsUsers: Bool
    
    var body: some View {
        ZStack {
            
            Image("homepage")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .offset(y: -20)
            
            VStack {
                HomeHeader(coins: coins, points: points)
                
                ScrollView {
                    VStack {
                        Button(action: {
                            showDrivingTowardsUsers = true
                            impact(intensity: .medium)
                        }) {
                            ParkingModeCard(geometry: geometry, showCard: $showParkingModeCard)
                                .shadow(color: Color("secondary").opacity(0.6), radius: 3, x: 2, y: 2)
                        }
                        .buttonStyle(BouncyButtonStyle())
                        .offset(x: showParkingModeCard ? 0 : -geometry.size.width)
                        
                        ParkTogglesCard(geometry: geometry)
                            .offset(y: showParkingModeCard ? 0 : -80)
                            .shadow(color: Color("secondary").opacity(0.6), radius: 3, x: 2, y: 2)
                        
//                        MapCard(geometry: geometry, showFullScreen: $showFullScreen)
//                            .offset(y: showParkingModeCard ? 0 : -80)
                        
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0), value: showParkingModeCard)


            }
            .padding(.top, getAdditionalTopPadding(bounds: geometry))
            .onChange(of: parkViewModel.myParkUser.parkingMode) { newValue in
                showParkingModeCard = newValue == ParkingMode.offering
            }
        }
    }
}


//struct MapCard: View {
//
//    var geometry: GeometryProxy
//
//    @Binding var showFullScreen: Bool
//
//    var body: some View {
//        ZStack {
//            ParkFinderMapView(shownAnnotation: .constant(nil), showCard: .constant(false), isMapCardView: true)
//                .frame(height: geometry.size.height/1.8)
//
//            VStack {
//
//                Spacer()
//
//                VStack(alignment: .leading, spacing: 5) {
//                    Text("Find nearby parking spots")
//                        .font(.system(.title3, design: .rounded))
//                        .bold()
//
//                    Text("Check which users are leaving their parking spots at the moment and grab one of them")
//                        .font(.system(.caption))
//                        .multilineTextAlignment(.leading)
//
//                }
//                .padding(.horizontal, 10)
//                .frame(maxWidth: .infinity)
//                .frame(height: geometry.size.height/(1.8*5.5))
//                .background(
//                    Rectangle()
//                        .foregroundColor(Color("background3"))
//                )
//
//            }
//            .animation(.easeInOut)
//
//        }
//
//        .frame(maxWidth: geometry.size.width - 60, maxHeight: 300)
//        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
//        .shadow(color: Color("secondary").opacity(0.6), radius: 3, x: 2, y: 2)
//        .padding(.top, 20)
//        .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
//
//    }
//}

struct HomeHeader: View {
    
    var coins: Int
    var points: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("OnePark")
                .font(.system(size: 45, weight: .heavy, design: .rounded))
            HStack {
                VStack(alignment: .leading) {
                    
                    
                    HeaderIndicator(iconName: "dollarsign.circle", iconColor: Color("gradient1"), text: String(222222))
                    
                    HeaderIndicator(iconName: "crown.fill", iconColor: Color("gradient3"), text: String(points))
                }
                
                Spacer()
                
                VStack {
                    Text("Shared parking spots today:")
                        .font(.system(size: 20, weight: .bold ,design: .rounded))
                        .multilineTextAlignment(.center)
                    Text("10")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 20)
        .frame(height: 300)
        .frame(maxWidth: .infinity)
        .background(BlurView(style: .systemChromeMaterial))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .offset(y: -10)
        .edgesIgnoringSafeArea(.top)
    }
}

struct HeaderIndicator: View {
    
    var iconName: String
    
    var iconColor: Color = .primary
    var text: String
    
    var body: some View {
        HStack(spacing: 0) {
            Image(systemName: iconName)
                .font(.system(size: 16, weight: .medium))
                .frame(width: 36, height: 36)
                .foregroundColor(iconColor)
            
            Text(text)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            
        }
//        .padding(.leading, 10)
//        .frame(maxWidth: 90, alignment: .trailing)
//        .background(Color("background3"))
//        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
//        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
//        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0.0, y: 10)
    }
}
