//
//  NewViewController.swift
//  Diplom-project
//
//  Created by Артем Томило on 13.06.22.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class NewViewController: UIViewController {
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblAdress: UILabel!
    @IBOutlet var lblRat: UILabel!
    @IBOutlet var lblNum: UILabel!
    @IBOutlet var lblWeb: UILabel!
    @IBOutlet var imView: UIImageView!
    
    private var placesClient: GMSPlacesClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placesClient = GMSPlacesClient.shared()
        
        avtoset()
    }
    
    func addMarker(in position: CLLocationCoordinate2D, name: String) {
        let marker = GMSMarker()
        marker.position = position
        marker.map = mapView
        marker.title = name
    }
    
    func avtoset() {
        let placeID = "ChIJWaiUyAzQ20YRakPEJ7388gY"
        
        let fields: GMSPlaceField = [.name, .formattedAddress, .phoneNumber, .rating, .website, .openingHours, .photos]
        placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil) { place, error in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            if let place = place {
                self.lblName.text = place.name
                
                self.lblAdress.text = place.formattedAddress
                
                self.lblNum.text = place.phoneNumber
                
                self.lblRat.text = "Rating: " + String(place.rating)
                
                let url = place.website
                let str = url?.absoluteString
                self.lblWeb.text = str
                
                let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]
                self.placesClient?.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
                    if let error = error {
                        print("Error loading photo metadata: \(error.localizedDescription)")
                        return
                    } else {
                        self.imView?.image = photo;
                        self.lblName?.attributedText = photoMetadata.attributions
                    }
                })
                
                self.addMarker(in: CLLocationCoordinate2D(latitude: 53.873961, longitude: 27.499368), name: place.name!)
                let zoom = GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: 53.873961, longitude: 27.499368), zoom: 16)
                self.mapView.animate(with: zoom)
            }
        }
    }
}
