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

enum ProfServices: Int, Hashable, Equatable, Codable, CaseIterable {
    case passengerTireFitting
    case truckTireFitting
    case carMaintenance
    case breakRepair
    case oilChange
    case carWash
    case seasonalTireStorage
    
    var title: String {
        switch self {
        case .passengerTireFitting:
            return "Passenger tire fitting"
        case .truckTireFitting:
            return "Truck tire fitting"
        case .carMaintenance:
            return "Car maintenance"
        case .breakRepair:
            return "Break repair"
        case .oilChange:
            return "Oil change"
        case .carWash:
            return "Car wash"
        case .seasonalTireStorage:
            return "Seasonal tire storage"
        }
    }
    
    var image: String {
        switch self {
        case .passengerTireFitting:
            return "tyre"
        case .truckTireFitting:
            return "tyre"
        case .carMaintenance:
            return "suspension"
        case .breakRepair:
            return "break"
        case .oilChange:
            return "oil"
        case .carWash:
            return "wash"
        case .seasonalTireStorage:
            return "tyreStorage"
        }
    }
}
