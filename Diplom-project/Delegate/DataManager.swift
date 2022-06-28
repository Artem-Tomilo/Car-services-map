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
    
    func encode(type: [Bool], key: String) {
        guard let data = try? JSONEncoder().encode(type) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
    
    func decode(key: String) -> [Bool] {
        guard let data = UserDefaults.standard.object(forKey: key) as? Data else { return [] }
        guard let conditionsArray = try? JSONDecoder().decode([Bool].self, from: data) else { return [] }

        return conditionsArray
    }
    
    func fetchServices(key: String) -> [Bool] {
        guard let data = UserDefaults.standard.object(forKey: key) as? Data else { return [] }
        guard let services = try? JSONDecoder().decode([Bool].self, from: data) else { return [] }
        
        return services
    }
    
    func changeValue(index: Int) {
        var services = fetchServices(key: serviceKey)
        
        var service = services.remove(at: index)
        
        service.toggle()
        
        services.insert(service, at: index)
        
//        save(type: services, key: serviceKey)
        
        print(services)
    }
}
