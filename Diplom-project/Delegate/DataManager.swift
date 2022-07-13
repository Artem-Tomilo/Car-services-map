//
//  DataManager.swift
//  Diplom-project
//
//  Created by Артем Томило on 27.06.22.
//

import UIKit

class DataManager {
    
    static let shared = DataManager()
    
    private let userDefaults = UserDefaults.standard
    
    private let serviceKey = "service"
    
    private let placesKey = "place"
    
    private init() {
        
    }
    
    func encodePlace(type: [Places]) {
        guard let data = try? JSONEncoder().encode(type) else { return }
        userDefaults.set(data, forKey: placesKey)
    }
    
    func decodePlace() -> [Places] {
        guard let data = userDefaults.object(forKey: placesKey) as? Data else { return [] }
        guard let places = try? JSONDecoder().decode([Places].self, from: data) else { return [] }
        
        return places
    }
    
    func encodeServices(type: Dictionary <ProfServices, Bool>) {
        guard let data = try? JSONEncoder().encode(type) else { return }
        userDefaults.set(data, forKey: serviceKey)
    }
    
    func decodeServices() -> Dictionary <ProfServices, Bool> {
        guard let data = userDefaults.object(forKey: serviceKey) as? Data else { return [:] }
        guard let conditionsArray = try? JSONDecoder().decode(Dictionary <ProfServices, Bool>.self, from: data) else { return [:] }
        
        return conditionsArray
    }
}
