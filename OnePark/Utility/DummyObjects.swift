//
//  DummyObjects.swift
//  DummyObjects
//
//  Created by Leonardo Angeli on 03/09/21.
//

import SwiftUI

let dummyVehicle = Vehicle(brand: "Tesla", model: "Model 3", length: 1.60, width: 4.69, height: 1.44, fuelType: .electric, wheels: 4, vehicleType: .car, displayBrand: "Tesla", displayModel: "Model 3")
let dummyUserVehicle = UserVehicle(id: "hq24bbub2s", brand: "tesla", model: "model3", color: "#4e5dbf", plate: "FK208DD", nickname: "tesddddddly", vehicleType: .car, year: 2017, fullVehicleInfo: dummyVehicle)

let dummyUserVehicle2 = UserVehicle(id: "hq24bb333ub2s", brand: "tesla", model: "model3", color: "#4e5dbf", plate: "CG405LL", nickname: "badasddds", vehicleType: .car, year: 2018, fullVehicleInfo: dummyVehicle)

let dummyParkingUser = ParkingUser(latitude: 42.75432, longitute: 39.535211, userId: "nwg30fnqofv0n", username: "dummyUser", vehicleId: "hq24bbub2s")

let exampleUser = UserPersonalInfo(firstName: "", lastName: "", email: "", username: "", phoneNumber: "")
let testUser = UserPersonalInfo(firstName: "Jimmy", lastName: "Bobby", email: "jobby_bimmy@gmail.com", username: "jimmyTheBobby", phoneNumber: "+33 3332224444")
