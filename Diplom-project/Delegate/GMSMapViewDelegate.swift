//
//  GMSMapViewDelegate.swift
//  Diplom-project
//
//  Created by Артем Томило on 1.06.22.
//

import GoogleMaps
import GoogleMapsUtils
import GooglePlaces
import UIKit

extension MapViewController: GMSMapViewDelegate {
    
    //MARK: - Did tap marker
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        guard let data = marker.userData as? MyAnnotations else { return true }
        getInfoAboutPlace(placeID: data.placeID, coordinate: CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude))
        
        NSLayoutConstraint.deactivate([
            infoViewConHid
        ])
        
        NSLayoutConstraint.activate([
            infoViewConShow
        ])
        view.setNeedsLayout()
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        if marker == mapView.selectedMarker {
            hideInfoView()
        }
        
        mapView.animate(toLocation: marker.position)
        if marker.userData is GMUCluster {
            mapView.animate(toZoom: mapView.camera.zoom + 1)
            NSLog("Did tap cluster")
            return true
        }
        NSLog("Did tap a normal marker")
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hideInfoView()
    }
    
    func hideInfoView() {
        NSLayoutConstraint.deactivate([
            infoViewConShow
        ])
        
        NSLayoutConstraint.activate([
            infoViewConHid
        ])
        view.setNeedsLayout()
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}
