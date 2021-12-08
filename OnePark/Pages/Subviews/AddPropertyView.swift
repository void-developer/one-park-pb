//
//  AddPropertyView.swift
//  AddPropertyView
//
//  Created by Leonardo Angeli on 04/09/21.
//

import SwiftUI
import CoreMedia

struct AddPropertyView: View {
    
    @ObservedObject var vehicleViewModel: VehicleViewModel
    
    @State var isLoading: Bool = false
    
    @Binding var showAddPropertyCard: Bool

    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                AddPropertyNavigationView(vehicleViewModel: vehicleViewModel, geometry: geometry, isLoading: $isLoading, showAddPropertyCard: $showAddPropertyCard)
                    
                
                if isLoading {
                    LoadingAnimationView(componentWidth: 150, componentHeight: 150)
                }
            }
            
        }
        .background(Color("bg3"))
        
    }
}

struct AddPropertyView_Previews: PreviewProvider {
    static var previews: some View {
        AddPropertyView(vehicleViewModel: VehicleViewModel(), showAddPropertyCard: .constant(true))
            .preferredColorScheme(.dark)
    }
}

struct AddPropertyNavigationView: View {
    
    @ObservedObject var vehicleViewModel: VehicleViewModel
    @EnvironmentObject var applicationVM: ApplicationViewModel
    
    @State private var selectedVehicleType: VehicleType?
    @State private var selectedBrand: KeyValuePair?
    @State private var selectedModel: KeyValuePair?
    
    @State private var licensePlate: String = ""
    
    @State private var nickname: String = ""
    @State private var color: Color = .white
    
    @State var navSelection: Int = 1
    @State private var vehicleYear: Int = Calendar.current.component(.year, from: Date())
    
    @State private var vehicleImage: UIImage?
    
    var geometry: GeometryProxy
    
    @Binding var isLoading: Bool

    @Binding var showAddPropertyCard: Bool
    
    @State var showingPicker: Int = 0
    
    
    func registerVehicle() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let error = ValidationUtility.validateStrings(strings: [selectedBrand?.id, selectedModel?.id, licensePlate, nickname]) {
                applicationVM.setErrors(error.localizedDescription)
                isLoading = false
                return
            } else if let nicknameError = ValidationUtility.validateString(string: nickname, minLength: 4, maxLength: 14) {
                print("\(nicknameError)")
                applicationVM.setErrors("The nickname of the vehicle must be between 4 and 14 alphanumercal characters")
                isLoading = false
                return
            }
            
            let newVehicle = UserVehicle(brand: selectedBrand!.id, model: selectedModel!.id, color: UIColor(color).toHexString(), plate: licensePlate.uppercased(), nickname: nickname, vehicleType: selectedVehicleType!, year: vehicleYear)
            
            if #available(iOS 15.0, *) {
                Task {
                    do {
                        try await vehicleViewModel.saveUserVehicle(vehicle: newVehicle)
                        self.isLoading = false
                        self.showAddPropertyCard = false
                    } catch { applicationVM.error = error as NSError }
                }
            } else {
                vehicleViewModel.saveUserVehicle(vehicle: newVehicle) { error in
                    if let error = error {
                        applicationVM.errors = error.localizedDescription
                    } else {
                        self.isLoading = false
                        self.showAddPropertyCard = false
                    }
                }
            }
        }
    }
    
    
    var body: some View {

        
         VStack(spacing: 30) {
             HStack {
                 Spacer()
                 
                 Text("Insert your car data...")
                    .bold()
                    .font(.system(.title2, design: .rounded))
                 
                 Spacer()
                 
                 CloseButton(show: $showAddPropertyCard)
                     
             }
             .padding(.top, 30)
             .padding(.horizontal)
            
            NavigationView {
                VStack {
                    NavigationLink(destination: VehicleGeneralInfo(selectedVehicleType: $selectedVehicleType, selectedBrand: $selectedBrand, selectedModel: $selectedModel, vehicleImage: $vehicleImage, vehicleVM: vehicleViewModel, showingPicker: $showingPicker, geometry: geometry), tag: 1, selection: Binding<Int?>($navSelection)) { EmptyView() }
                    
                    NavigationLink(destination: VehiclePersonalInfo(licensePlate: $licensePlate, year: $vehicleYear), tag: 2, selection: Binding<Int?>($navSelection)) { EmptyView().background(Color.green) }
                    NavigationLink(destination: VehicleCustomInfo(nickname: $nickname, color: $color, geometry: geometry), tag: 3, selection: Binding<Int?>($navSelection)) { EmptyView() }
                    
                    
                }
                
            }
            
            CardNavigationFooter(navSelection: $navSelection, action: registerVehicle)
                 .padding(.bottom, 30)
        }
        //.frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
        .overlay(
            PickerView(showingPicker: $showingPicker, geometry: geometry, selectedVehicleType: $selectedVehicleType, selectedBrand: $selectedBrand, selectedModel: $selectedModel, vehicleVM: vehicleViewModel)
        )
        .onChange(of: selectedModel) { newValue in
            if let newValue = newValue {
                vehicleViewModel.fetchVehicleImage(brand: selectedBrand!.id, model: newValue.id) { image in
                    if let image = image {
                        withAnimation {
                            vehicleImage = image
                        }
                    }
                }
            }
        }

    }
    
}



struct VehiclePickers: View {
    
    @Binding var selectedVehicleType: VehicleType?
    @Binding var selectedModel: KeyValuePair?
    @Binding var selectedBrand: KeyValuePair?
    
    @ObservedObject var vehicleViewModel: VehicleViewModel
    
    @Binding var showingPicker: Int
    
    var geometry: GeometryProxy
    
    var body: some View {
        
        VStack {
            HStack {
                
                VStack(alignment: .leading) {
                    Text("Vehicle")
                        .labelText()
                    Text("\(selectedVehicleType?.rawValue.capitalized ??  "Select a vehicle type...")")
                        .cardField()
                        .frame(height: 40)
                        .onTapGesture {
                            showingPicker = 1
                        }
                        
                }
                
                VStack(alignment: .leading) {
                    Text("Brand")
                        .labelText()
                    
                    Text("\(selectedBrand?.value ?? "Select a brand")")
                    .cardField()
                    .frame(height: 40)
                    .onTapGesture {
                        showingPicker = 2
                        print("BRAND TAPPED")
                    }

                }
            }
            .padding(.horizontal, 30)
            .frame(maxWidth: geometry.size.width)
            
            VStack(alignment: .leading) {
                Text("Model")
                    .font(.body)
                    .labelText()
                Text("\(selectedModel?.value ?? "Select a model")")
                    .cardField()
                    .frame(height: 40)
                    .highPriorityGesture(
                        TapGesture()
                            .onEnded { _ in
                                showingPicker = 3
                                print("MODEL TAPPED")
                            }
                    )
            }
            .frame(maxWidth: geometry.size.width)
            .padding(.horizontal, 30)
            .padding(.top, 10)

        }
        
    }
    
}

struct VehicleGeneralInfo: View {
    
    @Binding var selectedVehicleType: VehicleType?
    @Binding var selectedBrand: KeyValuePair?
    @Binding var selectedModel: KeyValuePair?
    
    @Binding var vehicleImage: UIImage?
    @ObservedObject var vehicleVM: VehicleViewModel
    
    @Binding var showingPicker: Int
    var geometry: GeometryProxy
    
    
    var body: some View {
        VStack(spacing: 20) {
            VehiclePickers(selectedVehicleType: $selectedVehicleType, selectedModel: $selectedModel, selectedBrand: $selectedBrand, vehicleViewModel: vehicleVM, showingPicker: $showingPicker, geometry: geometry
            )
            
            if let vehicleImage = vehicleImage {
                Image(uiImage: vehicleImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal)
                    .frame(maxHeight: 200)
                    .padding(.horizontal)
                    .transition(.opacity)
            } else {
                Image(systemName: "questionmark")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color("secondary"))
                    .padding(.horizontal)
                    .frame(maxHeight: 200)
                    .padding(.horizontal)
                    .transition(.opacity)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("bg3"))
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct VehiclePersonalInfo: View {
    
    @Binding var licensePlate: String
    @Binding var year: Int
    
    @State var showYearPicker: Bool = false
    
    var body: some View {
        VStack(spacing: 50) {
            
            VStack {
                Text("Year model of the vehicle")
                    .labelText()
                
                Button(action: {
                    self.showYearPicker = true
                }) {
                    Text(String(year))
                }
                .cardField()
                
                .frame(maxWidth: 300, maxHeight: 40)
                .popover(isPresented: $showYearPicker) {
                    Picker("Vehicle year", selection: $year) {
                        ForEach(1950..<2021, id: \.self) { year in
                            Text(String(year))
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(maxWidth: 300)
                }
            }
            
            VStack {
                Text("License Plate")
                    .autocapitalization(.allCharacters)
                    .labelText()

                
                TextField("XX444DD", text: $licensePlate)
                    .cardField()
                    .frame(height: 40)
                    .frame(maxWidth: 300)
                    .padding(.bottom, 20)
                

                LicensePlate(licensePlate: licensePlate)
                    .frame(maxWidth: 250)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 20)

        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("bg3"))
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}


struct VehicleCustomInfo: View {
    
    @Binding var nickname: String
    @Binding var color: Color

    var geometry: GeometryProxy
    
    var body: some View {
        VStack(spacing: 40) {
            
            VStack(alignment: .leading) {
                Text("Pick a nickname for your vehicle")
                    .labelText()
                    
                TextField("nickynamy", text: $nickname)
                    .cardField()
                    .frame(maxWidth: 300, maxHeight: 40)
                
            }
            
            VStack(spacing: 20) {
                ColorPicker("Vehicle color: ", selection: $color)
                    
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .foregroundColor(color)
                    .frame(maxWidth: 300)
                    .frame(maxHeight: 200)
                    .shadow(color: Color.black.opacity(0.4), radius: 2, x: 1, y: 1)
            }
            
            
                
        }
        .padding(.horizontal, 30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("bg3"))
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct CardNavigationFooter: View {
    
    @Binding var navSelection: Int
    
    var action: () -> Void

    var body: some View {
        
        return HStack {
            Button(action: {
                navSelection -= 1
            }) {
                HStack {
                    Image(systemName: "chevron.backward")
                    Text("Back")
                }
            }
            .disabled(navSelection <= 1)
            
            Spacer()
            
            Button(action: {
               if navSelection < 3 {
                   navSelection += 1
               } else if navSelection == 3 {
                   action()
               }
            })  {
                HStack {
                    Text(navSelection == 3 ? "Add" : "Next")
                    Image(systemName: "chevron.forward")
                }
            }
            .disabled(navSelection >= 4)
        }
        .padding(.horizontal, 20)
    }
}

struct PickerView: View {
    
    @Binding var showingPicker: Int
    var geometry: GeometryProxy
    
    @Binding var selectedVehicleType: VehicleType?
    @Binding var selectedBrand: KeyValuePair?
    @Binding var selectedModel: KeyValuePair?
    
    @ObservedObject var vehicleVM: VehicleViewModel
    
    @State private var vehicleBrandOptions: [KeyValuePair] = []
    @State private var vehicleModelOptions: [KeyValuePair] = []
    
    var body: some View {
        VStack {
            VStack {
                if showingPicker != 0 {
                    VStack(spacing: 0) {
                        
                        HStack {
                            Spacer()
                            
                            Button(action: {showingPicker = 0}) {
                                Text("Done")
                            }
                        }
                        .padding(.horizontal, 30)
                        .frame(width: geometry.size.width, height: 40)
                        .background(Color("light-gray"))
                        
                        VStack {
                            switch showingPicker {
                                case 1:
                                    vehicleTypePicker
                                case 2:
                                    brandPicker
                                case 3:
                                    modelPicker
                                default:
                                    EmptyView()
                            }
                        }
                        .background(BlurView(style: .systemChromeMaterial))
                    }
                    .animation(.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0))
                    .transition(AnyTransition.move(edge: .bottom))
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
        .onChange(of: selectedVehicleType) { newValue in
            DispatchQueue.main.async {
                selectedBrand = nil
                vehicleVM.fetchAllFullVehicles(vehicleType: newValue?.rawValue, completion: { brands in
                    vehicleBrandOptions = brands
                })
            }
            
        }
        .onChange(of: selectedBrand) { newValue in
            if let newValue = newValue {
                DispatchQueue.main.async {
                    selectedModel = nil
                    vehicleVM.fetchAllFullVehicles(brand: newValue.id, vehicleType: selectedVehicleType?.rawValue) { models in
                        vehicleModelOptions = models
                    }
                }
            }
        }
    }
    
    private var vehicleTypePicker: some View {
        Picker("Vehicle type:", selection: $selectedVehicleType) {
            ForEach(VehicleType.allCases) { vehicleType in
                Text(vehicleType.rawValue.capitalized)
                    .tag(vehicleType as VehicleType?)
            }
        }
        .pickerStyle(WheelPickerStyle())
    }
    
    private var modelPicker: some View {
        Picker("Model:", selection: $selectedModel) {
            Text("Default").tag(nil as KeyValuePair?)
            ForEach(vehicleModelOptions) { modelOption in
                Text(modelOption.value)
                    .tag(modelOption as KeyValuePair?)
            }
        }
        .pickerStyle(WheelPickerStyle())
    }
    
    private var brandPicker: some View {
        Picker("Brand:", selection: $selectedBrand) {
            Text("Default").tag(nil as KeyValuePair?)
            ForEach(vehicleBrandOptions) { brandOption in
                Text(brandOption.value)
                    .tag(brandOption as KeyValuePair?)
            }
        }
        .pickerStyle(WheelPickerStyle())
    }
}
