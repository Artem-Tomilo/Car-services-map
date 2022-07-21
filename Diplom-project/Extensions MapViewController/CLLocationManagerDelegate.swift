//
//  CLLocationManagerDelegate.swift
//  Diplom-project
//
//  Created by Артем Томило on 1.06.22.
//

import CoreLocation
import UIKit
import GoogleMaps

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted:
            requestUserOpensSettings()
            getObjectsData(radius: nil)
        case .denied:
            requestUserOpensSettings()
            getObjectsData(radius: nil)
        case .authorizedAlways:
            changeCameraToUserLocation(manager: manager)
        case .authorizedWhenInUse:
            changeCameraToUserLocation(manager: manager)
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location was changed")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func requestUserOpensSettings() {
        let alert = UIAlertController(title: "Location access not allowed", message: "Please, allow the app access to location to see your current location", preferredStyle: .alert)
        let action = UIAlertAction(title: "Open settings", style: .default) { _ in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
        }
        alert.addAction(action)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func changeCameraToUserLocation(manager: CLLocationManager) {
        let camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: manager.location?.coordinate.latitude ?? 0, longitude: manager.location?.coordinate.longitude ?? 0), zoom: 12)
        mapView.animate(to: camera)
        getObjectsData(radius: 7000)
    }
}
