//
//  CLLocationManagerDelegate.swift
//  Diplom-project
//
//  Created by Артем Томило on 1.06.22.
//

import CoreLocation

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            return
        case .denied:
            return
        case .restricted:
            manager.requestWhenInUseAuthorization()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        default:
            manager.requestWhenInUseAuthorization()
        }
        
//        switch status {
//            case .restricted:
//              print("Location access was restricted.")
//            case .denied:
//              print("User denied access to location.")
//              // Display the map using the default location.
//              mapView.isHidden = false
//            case .notDetermined:
//              print("Location status not determined.")
//            case .authorizedAlways: fallthrough
//            case .authorizedWhenInUse:
//              print("Location status is OK.")
//            @unknown default:
//              fatalError()
//            }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location was changed")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
