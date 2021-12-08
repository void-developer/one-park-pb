//
//  TabView.swift
//  TabView
//
//  Created by Leonardo Angeli on 20/08/21.
//

import SwiftUI

struct TabBarView: View {
    
    @EnvironmentObject var applicationVM: ApplicationViewModel
    @EnvironmentObject var vehicleVM: VehicleViewModel
    @EnvironmentObject var parkVM: ParkViewModel
    @State private var showDrivingUsersSheet: Bool = false
    
    @State private var showErrorsCard: Bool = false
    @State private var showAwaitingUserCard: Bool = false
    
    @State var selectedPage: Page = .home;
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor(Color("background4").opacity(0.90))
//        UITabBar.appearance().tintColor = UIColor(Color("red"))
//        UITabBar.appearance().unselectedItemTintColor = UIColor(Color.green)
        UITabBar.appearance().isTranslucent = true
     }

    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                switch selectedPage {
                    case .home:
                        HomeView(showDrivingTowardsUsers: $showDrivingUsersSheet)
                    case .propertyManager:
                        PropertyManagerView()
                    case .map:
                        ParkManagerMapView()
                    case .profile:
                        ProfileView()
                    default:
                        EmptyView()
                }

                RoundedTabView(selectedPage: $selectedPage)
                
                VStack {
                    Spacer()
                    
                    SideNotesCard(width: geometry.size.width, height: 150, header: "Ooops!", content: $applicationVM.errors, show: $showErrorsCard, nsError: $applicationVM.error)
                        
                }
                
                if showAwaitingUserCard {
                    ZStack {
                            BlurView(style: .systemChromeMaterial)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .transition(.opacity)
                            
                            ParkConfirmationCardView(parkingUser: Binding(
                                get: {return parkVM.awaitingForConfirmationUser ?? dummyParkingUser}, set: {parkVM.awaitingForConfirmationUser = $0}), showCard: $showAwaitingUserCard)
                                .frame(minWidth: 270, idealWidth: geometry.size.width-60, maxWidth: 500, minHeight: 500, idealHeight: geometry.size.height-100, maxHeight: 800, alignment: .center)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 50)
                                .transition(AnyTransition.move(edge: .bottom).animation(.spring(response: 0.5, dampingFraction: 0.8, blendDuration: 0)))
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
                    .edgesIgnoringSafeArea(.all)
                }
            }
            .edgesIgnoringSafeArea(.top)
            .onChange(of: applicationVM.errors) { newValue in
                if !showErrorsCard {
                    showErrorsCard = !newValue.isEmpty
                }
            }
            .onChange(of: applicationVM.error) { newValue in
                if !showErrorsCard {
                    showErrorsCard = newValue != nil
                }
            }
            .onChange(of: parkVM.awaitingForConfirmationUser) { newValue in
                withAnimation {
                    showAwaitingUserCard = newValue != nil
                }
            }
        }
        .onAppear {
            if #available(iOS 15.0, *) {
                Task {
                    try await vehicleVM.fetchMyVehicles()
                }
            } else {
                vehicleVM.fetchMyVehicles()
            }
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    static var previews: some View {
        let parkStore = ParkViewModel()
        parkStore.awaitingForConfirmationUser = dummyParkingUser
        return TabBarView()
            .environmentObject(parkStore)
            .environmentObject(UserViewModel(User(personalInfo: testUser)))
            .environmentObject(ApplicationViewModel())
            .environmentObject(VehicleViewModel())
            .preferredColorScheme(.light)
    }
}

struct RoundedTabView: View {
    
    @Binding var selectedPage: Page
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .shadow(color: Color("shadow").opacity(0.3), radius: 3, x: -1, y: -1)
                
                HStack(alignment: .top) {
                    TabBarIcon(icon: "house.fill", text: "Home", selectedPage: $selectedPage, pageValue: .home)
                    Spacer()
                    TabBarIcon(icon: "car.fill", text: "Property", selectedPage: $selectedPage, pageValue: .propertyManager)
                    Spacer()
                    TabBarIcon(icon: "map.fill", text: "Map", selectedPage: $selectedPage, pageValue: .map)
                    Spacer()
                    TabBarIcon(icon: "person.fill", text: "Profile", selectedPage: $selectedPage, pageValue: .profile)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .padding(.horizontal, 35)
                .padding(.top, 25)
            }
            .foregroundColor(.white)
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .offset(y: 10)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct TabBarIcon: View {
    
    var icon: String
    var text: String
    
    @Binding var selectedPage: Page
    
    var pageValue: Page
    
    var body: some View {
        Button(action: {selectedPage = pageValue}) {
            VStack {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 27, alignment: .center)
                Text(text)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .bold()
            }
            .foregroundColor(selectedPage == pageValue ? Color("gradient3") : Color("disabled"))
        }
    }
}
