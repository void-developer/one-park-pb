//
//  PropertyManagerView.swift
//  PropertyManagerView
//
//  Created by Leonardo Angeli on 03/09/21.
//

import SwiftUI
import CoreMedia

struct PropertyManagerView: View {
    
    @EnvironmentObject var vehicleVM: VehicleViewModel
    
    @EnvironmentObject private var parkVM: ParkViewModel
    
    @State var showAddVehicleModal: Bool = false
    @State var currentVehicleId: String = "addbutton"
    
    @State var animatedVehicleId: String? = nil
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                HStack(alignment: .bottom) {
                    Image("wheels")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 220, alignment: .center)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                
                HStack {
                    Image("car-turret")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: geometry.size.height)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                
                VStack {
                    Text("Property Manager")
                        .bold()
                        .font(.system(.largeTitle, design: .rounded))

                    Spacer()

                    TabView(selection: $currentVehicleId) {
                        ForEach(vehicleVM.personalVehicles) { vehicle in
                                //TODO: Editable car
                            VehicleCardItem(vehicleVM: vehicleVM, vehicle: vehicle, animatedVehicleId: $animatedVehicleId)
                                .tabItem({
                                    EmptyView()
                                })
                                .tag(vehicle.id!)
                            
                        }
                        
                        Button(action: {showAddVehicleModal = true}) {
                            Image(systemName: "plus.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color("gradient3").opacity(0.4))
                                .frame(width: geometry.size.width - 150)
                        }
                        .tabItem({
                            EmptyView()
                        })
                        .tag("addbutton")
                        
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    
                    Spacer()

                    //TODO: Button should select as current using car
                    if currentVehicleId != "add" {
                        SelectCurrentCarButton(geometry: geometry, currentVehicleId: currentVehicleId)
                            .transition(.opacity)
                    }

                }
                .padding(.top, 20)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

                AddPropertyCard(vehicleVM: vehicleVM, geometry: geometry, showAddPropertyCard: $showAddVehicleModal)

            }
            .onChange(of: parkVM.myParkUser.vehicleId) { newValue in
                animatedVehicleId = newValue
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    animatedVehicleId = nil
                }
            }
        }
        .onAppear(perform: {
            if vehicleVM.personalVehicles.count > 0 {
                withAnimation {
                    currentVehicleId = vehicleVM.personalVehicles[0].id!
                }
            }
        })
    }
}

struct PropertyManagerView_Previews: PreviewProvider {
    static var previews: some View {
        let vehicleViewModel = VehicleViewModel()
        vehicleViewModel.personalVehicles.append(dummyUserVehicle)
        vehicleViewModel.personalVehicles.append(dummyUserVehicle2)
        return PropertyManagerView()
            .preferredColorScheme(.light)
            .environmentObject(ParkViewModel())
            .environmentObject(ApplicationViewModel())
            .environmentObject(vehicleViewModel)

    }
}

struct VehiclePropertyDetails: View {
    
    @ObservedObject var vehicleViewModel: VehicleViewModel
    
    var vehicle: UserVehicle
    var geometry: GeometryProxy
    
    
    var body: some View {
        VStack {
            VehicleCardHeader(vehicleViewModel: vehicleViewModel, vehicle: vehicle, geometry: geometry)

            Spacer()

            if let vehicleSpecs = vehicle.fullVehicleInfo,
               let vehicleImage = vehicleSpecs.image {
                Image(uiImage: vehicleImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: geometry.size.width - 80, maxHeight: 200)
                    .transition(.opacity)
            } else {
                Image(systemName: "car")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color("gradient3").opacity(0.4))
                    .frame(maxWidth: geometry.size.width - 80, maxHeight: 200)
                    .padding(.bottom, 10)
                    .transition(.opacity)
            }
            
            Spacer()
            
            LicensePlate(licensePlate: vehicle.plate)
                .frame(width: 250)
            
        }
    }
}

struct SelectCurrentCarButton: View {
    
    var geometry: GeometryProxy
    var currentVehicleId: String
    @EnvironmentObject private var parkVM: ParkViewModel
    
    var body: some View {
        Button(action: {
                parkVM.setCurrentVehicle(vehicleId: currentVehicleId)
        }) {
            Text("SELECT")
                .bold()
                .font(Font.custom("rubik", size: 25, relativeTo: Font.TextStyle.title3))
                .frame(maxWidth: geometry.size.width - 60, maxHeight: 60)
                .foregroundColor(Color.white)
                .background(currentVehicleId == parkVM.myParkUser.vehicleId ? Color.gray : Color("button-color"))
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .padding(.horizontal, 30)
                .shadow(color: Color.black.opacity(0.4), radius: 3, x: 1, y: 1)
                .animation(.easeInOut, value: currentVehicleId)
        }
        .buttonStyle(BouncyButtonStyle())
        .disabled(currentVehicleId == parkVM.myParkUser.vehicleId)
    }
}

struct AddPropertyCard: View {
    
    @ObservedObject var vehicleVM: VehicleViewModel
    var geometry: GeometryProxy
    
    @Binding var showAddPropertyCard: Bool
    
    @State var dragState: CGSize = .zero
    @State var animatedShow: Bool = false
    
    var body: some View {
        AddPropertyView(vehicleViewModel: vehicleVM, showAddPropertyCard: $showAddPropertyCard)
                .frame(maxHeight: geometry.size.height)
                .frame(height: geometry.size.height/1.3)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color("shadow").opacity(0.6), radius: 3, x: 4, y: 5)
                .offset(x: showAddPropertyCard ? 0 : geometry.size.width)
                .padding(.horizontal)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(BlurView(style: .systemChromeMaterial))
                .opacity(showAddPropertyCard ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0), value: showAddPropertyCard)
                .edgesIgnoringSafeArea(.all)

    }
}

struct VehicleCardHeader: View {
    
    @ObservedObject var vehicleViewModel: VehicleViewModel
    
    var vehicle: UserVehicle
    var geometry: GeometryProxy
    
    @EnvironmentObject var parkVM: ParkViewModel
    @EnvironmentObject var applicationVM: ApplicationViewModel
    
    var body: some View {
        HStack(alignment: .center) {
            Text(vehicle.nickname)
                .bold()
                .font(Font.custom("rubik", size: 45, relativeTo: Font.TextStyle.title))
                .minimumScaleFactor(0.4)
                .lineLimit(1)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    if let vehicleId = vehicle.id {
                        print("\(vehicleId)")
                    }
                }
            }) {
                Image(systemName: "pencil")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .frame(maxWidth: 20, maxHeight: 20)
                    .foregroundColor(Color("button-color"))
                    .padding(10)
            }
            .background(Color("light-gray").opacity(0.6))
            .clipShape(Circle())
            
            Button(action: {
                withAnimation {
                    if let vehicleId = vehicle.id {
                        if let currentVehicleId = parkVM.myParkUser.currentVehicle?.id,
                           currentVehicleId == vehicleId && parkVM.myParkUser.parkingMode != .none {
                            applicationVM.setApplicationError(ApplicationError.vehicleInUse as NSError)
                        }

                        if #available(iOS 15.0, *) {
                            Task {
                                try await vehicleViewModel.deleteUserVehicle(vehicleId: vehicleId)
                            }
                        } else {
                            vehicleViewModel.deleteUserVehicle(vehicleId: vehicleId)
                        }
                    }
                }
            }) {
                Image(systemName: "trash.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .foregroundColor(Color("error-red"))
                    .padding(10)
            }
            .background(Color("light-gray").opacity(0.6))
            .clipShape(Circle())
        }
        .padding(.horizontal, 5)
        .padding(.bottom, 20)
    }
}

