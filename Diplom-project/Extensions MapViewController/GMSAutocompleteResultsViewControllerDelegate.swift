//
//  GMSAutocompleteResultsViewControllerDelegate.swift
//  Diplom-project
//
//  Created by Артем Томило on 21.07.22.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils
import GoogleSignIn
import GooglePlaces

extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        
        for marker in markerArray {
            if place.coordinate.latitude == marker.position.latitude && place.coordinate.longitude == marker.position.longitude {
                
                let camera = GMSCameraPosition(target: place.coordinate, zoom: 13)
                mapView.animate(to: camera)
                
                guard let data = marker.userData as? Places else { return }
                getInfoAboutPlace(placeID: data.placeID, coordinate: CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude))
                
                self.place = data
                
                if self.place == nil || self.place!.favoriteStatus == false {
                    markerInfoView.heartButton.setImage(UIImage(named: "heartClear"), for: .normal)
                } else {
                    markerInfoView.heartButton.setImage(UIImage(named: "heartRed"), for: .normal)
                }
                
                showMarkerInfoView()
                
                mapView.selectedMarker = marker
            }
        }
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
