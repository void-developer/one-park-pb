//
//  CardContentView.swift
//  CardContentView
//
//  Created by Leonardo Angeli on 02/09/21.
//

import SwiftUI


struct AnnotationCardView: View {
    
    @Binding var showCard: Bool
    @State private var showFullScreenCard: Bool = false

    @Binding var shownAnnotation: ParkAnnotation
    
    @State private var dragState: CGSize = .zero
    @State private var tap: Bool = false
    @State private var successAnimationActive: Bool = false
    
    var isMapCardView: Bool

    @StateObject private var vehicleViewModel: VehicleViewModel = VehicleViewModel()
    @EnvironmentObject private var parkViewModel: ParkViewModel

    @State var parkingUser: ParkingUser?
    
    @EnvironmentObject private var applicationVM: ApplicationViewModel
    
    var body: some View {
       
        GeometryReader { geometry in
            let cardDragHandleHeight: CGFloat =  20 + 5 + 5 + 15
            let topContentHeight: CGFloat = 77 + 60 + 100
            let totalOffset = topContentHeight + cardDragHandleHeight + 10 - (isMapCardView ? geometry.frame(in: .local).maxY/2
                                                                              : 0)
               
            ZStack {
            
                VStack {
                    CardDragHandle(showCard: $showCard, dragState: $dragState, showFullScreen: $showFullScreenCard, dismissHeight: 100, showFullScreenHeight: 100)
                    ScrollView {
                        VStack {
                            CardContentView(tap: $tap, shownAnnotation: $shownAnnotation, successAnimationActive: $successAnimationActive, geometry: geometry)
                                .frame(maxHeight: topContentHeight, alignment: .top)
                            
                            Divider()
                                .padding(.horizontal, 20)
                            
                            
                            if var parkingUser = parkingUser {
                                UserVehicleInfoView(parkingUser: Binding(get: { parkingUser }, set: { parkingUser = $0 }))
                                    .transition(.opacity)
                            }
                           
                        }
                    }
                }

            }
            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height, alignment: .top)
            .background(Color("background3"))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .offset(y: showCard ? dragState.height + (showFullScreenCard ? 0 : geometry.frame(in: .local).maxY - totalOffset) : geometry.size.height)
            .animation(.spring(response: 0.5, dampingFraction: 0.6, blendDuration: 0))
            .onChange(of: showCard) { newValue in
                if newValue {
                    do {
                        parkingUser = try parkViewModel.getParkingUser(userId: shownAnnotation.ownerId, parkingMode: ParkingMode.of(shownAnnotation.type))
                    } catch { applicationVM.setApplicationError(error as NSError) }
                }
            }
        }
    }
}

struct CardContentView: View {
    
    @Binding var tap: Bool
    
    @Binding var shownAnnotation: ParkAnnotation
    
    @Binding var successAnimationActive: Bool
    
    @EnvironmentObject var parkStore: ParkViewModel
    
    var geometry: GeometryProxy
    
    @State var isReservedAnnotation: Bool = false
    
    @EnvironmentObject private var applicationVM: ApplicationViewModel
    
    func setAsDestinationUser() -> Void {
        parkStore.destinationParkingSpot = ParkingUser(latitude: shownAnnotation.coordinate.latitude, longitute: shownAnnotation.coordinate.longitude, userId: shownAnnotation.ownerId, username: shownAnnotation.ownerUsername)
        parkStore.addDestination(destinationUserId: shownAnnotation.ownerId)
        haptic(type: .success)
    }
    
    func clearDestinationUser() -> Void {
        parkStore.cancelDestination(destinationUserId: shownAnnotation.ownerId)
        haptic(type: .success)
    }
    
    func handleParkingConfirmation(_ awaiting: Bool = true) {
        if #available(iOS 15.0.0, *) {
            Task {
                do { try await parkStore.setWaitingForUserConfirmation(awaiting); haptic(type: .success) }
                catch { applicationVM.setApplicationError(error as NSError)}
            }
        } else {
            parkStore.setWaitingForUserConfirmation(awaiting: awaiting, completion: { error in
                if let error = error {
                    applicationVM.setApplicationError(error as NSError)
                } else {
                    haptic(type: .success)
                }
            })
        }
    }
    
    var body: some View {
        
        VStack(spacing: 20) {
            HStack(spacing: 20) {
                shownAnnotation.type.image()
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color("accent"))
                    .frame(width: 77, height: 77)
                
                
                Text((shownAnnotation.title ?? "")!)
                    .bold()
                    .font(.system(.title, design: .rounded))
                    .multilineTextAlignment(.leading)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(shownAnnotation.type.description())
                .font(.system(.body, design: .rounded))
                .frame(height: 50)
            
            if shownAnnotation.type == .offering {
                HStack {
                    Button(action: {
                        if isReservedAnnotation {
                            clearDestinationUser()
                        } else {
                            setAsDestinationUser()
                        }
                    }) {
                        Text(isReservedAnnotation ? "Cancel Drive-to" : "Reserve (kinda)")
                        .bold()
                        .font(.system(.title3, design: .rounded))
                        .frame(maxWidth: isReservedAnnotation ? geometry.size.width/2 : .infinity)
                        .frame(height: 60)
                        .background(isReservedAnnotation ? Color("error-red") : Color("button-color"))
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                    .buttonStyle(BouncyButtonStyle())
                    
                    if isReservedAnnotation {
                        Button(action: {
                            handleParkingConfirmation(!parkStore.isWaitingForParkingConfirmation)

                        }) {
                            Text("\(parkStore.isWaitingForParkingConfirmation ? "I'm not there" : "I'm here!")")
                                .bold()
                                .font(.system(.title3, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .background(parkStore.isWaitingForParkingConfirmation ? Color("error-red") : Color("button-color"))
                                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                        }
                        .buttonStyle(BouncyButtonStyle())
                        .transition(AnyTransition.scale(scale: 0.12))
                    }
                }
            }
            
            
        }
        .padding(.horizontal)
        .onChange(of: parkStore.destinationParkingSpot?.userId) { newValue in
            isReservedAnnotation = parkStore.destinationParkingSpot?.userId == shownAnnotation.ownerId
        }
    }
}

struct CardContentView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geometry in
            AnnotationCardView(showCard: .constant(true), shownAnnotation: .constant(dummyParkAnnotation), isMapCardView: false, parkingUser: dummyParkingUser)
                .environmentObject(UserViewModel())
                .environmentObject(ParkViewModel())
        }
    }
}


struct SuccessAnimation: View {
    
    var isMapCardView: Bool
    var geometry: GeometryProxy
    @Binding var successAnimationActive: Bool
    
    var animationMaxHeight: CGFloat = 200
    var body: some View {
        VStack {
            SuccessAnimationView(componentWidth: 160, componentHeight: 160, disappearDelay: $successAnimationActive, additionalOffset: -(20 + geometry.safeAreaInsets.bottom))
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .frame(maxHeight: isMapCardView ? geometry.frame(in: .local).maxY : animationMaxHeight)
                .onTapGesture {
                    successAnimationActive = false
                }
            Spacer()
        }
        .frame(alignment: .top)
    }
}
