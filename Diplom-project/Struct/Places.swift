//
//  Places.swift
//  Diplom-project
//
//  Created by Артем Томило on 1.06.22.
//

struct Places: Codable {
    var latitude: Double
    var longitude: Double
    var name: String
    var placeID: String
    var services: Set<ProfServices>
    var favoriteStatus: Bool
}

enum ProfServices: Hashable, Equatable, Codable, CaseIterable {
    case passengerTireFitting
    case truckTireFitting
    case carMaintenance
    case breakRepair
    case oilChange
    case carWash
    case seasonalTireStorage
}
