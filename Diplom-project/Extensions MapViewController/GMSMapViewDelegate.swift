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
        
        guard let data = marker.userData as? Places else { return true }
        getInfoAboutPlace(placeID: data.placeID, coordinate: CLLocationCoordinate2D(latitude: data.latitude, longitude: data.longitude))
        
        place = data
        
        if place == nil || place!.favoriteStatus == false {
            markerInfoView.heartButton.setImage(UIImage(named: "heartClear"), for: .normal)
        } else {
            markerInfoView.heartButton.setImage(UIImage(named: "heartRed"), for: .normal)
        }
        
        showMarkerInfoView()
        
        if marker == mapView.selectedMarker {
            hideMarkerInfoView()
            polyline.map = nil
        } else {
            polyline.map = nil
        }
        
        mapView.animate(toLocation: marker.position)
        
        return false
    }
    
    //MARK: - Did tap at coordinate
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        hideMarkerInfoView()
        polyline.map = nil
    }
    
    //MARK: - Hide and show MarkerinfoView func
    
    func hideMarkerInfoView() {
        
        NSLayoutConstraint.deactivate([
            showMarkerInfoViewConstraint,
            hidingButtonUpConstraint
        ])
        
        NSLayoutConstraint.activate([
            hiddenMarkerInfoViewConstraint,
            hidingButtonDownConstraint
        ])
        view.setNeedsLayout()
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        } completion: { _ in
            self.markerInfoView.removeFromSuperview()
            self.configureMarkerInfoView()
        }
    }
    
    func showMarkerInfoView() {
        
        markerInfoView.lockView()
        UIView.animate(withDuration: 2) {
            self.markerInfoView.unlockView()
        }
        
        NSLayoutConstraint.deactivate([
            hiddenMarkerInfoViewConstraint,
            hidingButtonDownConstraint
        ])
        
        NSLayoutConstraint.activate([
            showMarkerInfoViewConstraint,
            hidingButtonUpConstraint
        ])
        view.setNeedsLayout()
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}
