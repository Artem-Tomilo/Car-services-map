//
//  GMSMapViewDelegate.swift
//  Diplom-project
//
//  Created by Артем Томило on 1.06.22.
//

import GoogleMaps
import GoogleMapsUtils

extension MapViewController: GMSMapViewDelegate {
    
    //MARK: - TapInfoWindowOfMarker

    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        let alert = UIAlertController(title: "Do you want to delete this marker?", message: "", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Delete", style: .destructive) { _ in
            marker.map = nil
            for i in self.jsonMarker {
                if marker.position.longitude == i.longitude && marker.position.latitude == i.latitude {
                    self.jsonMarker.removeAll(where: {$0.latitude == i.latitude && $0.longitude == i.longitude})
                    let encoder = JSONEncoder()
                    let data = try! encoder.encode(self.jsonMarker)
                    try! data.write(to: MapViewController.jsonPath)
                }
            }
        }
        let secondAction = UIAlertAction(title: "No", style: .cancel) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(action)
        alert.addAction(secondAction)
        present(alert, animated: true)
    }
    
    //MARK: - MarkerInfoWindow
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        print("123")
//        let zoom = GMSCameraUpdate.zoom(to: 15)
//        mapView.animate(with: zoom)
        return nil
    }
    
    //MARK: - LongPressInfoWindow

    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        
    }
    
    //MARK: - LongPressAtCoordinate
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        let latitude: Double = coordinate.latitude
        let longitude: Double = coordinate.longitude

        let alert = UIAlertController(title: "Add place name", message: "", preferredStyle: .alert)
        alert.addTextField { (textField: UITextField!) -> Void in
            textField.placeholder = "Name"
        }
        let action = UIAlertAction(title: "Enter", style: .default) { action in
            if let textField = alert.textFields?[0] {
                self.text = textField.text!

                self.addMarker(in: coordinate, name: self.text)

                let result = MyAnnotations(latitude: latitude, longitude: longitude, name: self.text)
                self.jsonMarker.append(result)

                let encoder = JSONEncoder()
                let data = try! encoder.encode(self.jsonMarker)
                try! data.write(to: MapViewController.jsonPath)
                print(self.jsonMarker)
            }
        }
        let secondAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(action)
        alert.addAction(secondAction)
        present(alert, animated: true)
    }
    
    //MARK: - TapPOIWithPlaceID

    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        print("You tapped \(name)")
//        let infoMarker = GMSMarker()
//        infoMarker.position = location
//        infoMarker.title = name
//        infoMarker.opacity = 0;
//        infoMarker.infoWindowAnchor.y = 1
//        infoMarker.map = mapView
//        mapView.selectedMarker = infoMarker
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
      // center the map on tapped marker
      mapView.animate(toLocation: marker.position)
      // check if a cluster icon was tapped
      if marker.userData is GMUCluster {
        // zoom in on tapped cluster
        mapView.animate(toZoom: mapView.camera.zoom + 1)
        NSLog("Did tap cluster")
        return true
      }
      NSLog("Did tap a normal marker")
      return false
    }
}
