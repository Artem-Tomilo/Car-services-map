//
//  MapViewController.swift
//  Diplom-project
//
//  Created by Артем Томило on 1.06.22.
//

import UIKit
import GoogleMaps
import GoogleMapsUtils
import GoogleSignIn
import GooglePlaces
import CoreLocation
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseStorage
import Alamofire
import SwiftyJSON

class MapViewController: UIViewController {
    
    @IBOutlet var markerInfoView: MarkerInfoView!
    
    var mapView: GMSMapView!
    let someView = UIView()
    let viewForUserData = UIView()
    let avatarView = UIImageView()
    let clearView = UIView()
    let tableView = UITableView()
    let nameLabel = UILabel()
    
    let changeStyleButton = UIButton()
    let minusZoomButton = UIButton()
    let plusZoomButton = UIButton()
    let showMenuButton = UIButton()
    let signOutButton = UIButton()
    let filterButton = UIButton()
    let trafficButoon = UIButton()
    
    var showMenuConstraint: NSLayoutConstraint!
    var hiddenMenuConstraint: NSLayoutConstraint!
    var showClearViewConstraint: NSLayoutConstraint!
    var hiddenClearViewConstraint: NSLayoutConstraint!
    var showMarkerInfoViewConstraint: NSLayoutConstraint!
    var hiddenMarkerInfoViewConstraint: NSLayoutConstraint!
    
    var lightStyle = false
    var showTableView = false
    var trafficFlag = false
    
    let ref = Database.database().reference().child("users")
    let storage = Storage.storage()
    lazy var avatarsRef = storage.reference().child("avatars/")
    
    var placesArray: [Places] = []
    var users: [Person] = []
    var markerArray: [GMSMarker] = []
    
    let manager = CLLocationManager()
    
    var cluster: GMUClusterManager!
    
    var polyline = GMSPolyline()
    
    let listTableViewMenu = ["Advanced filter", "My favorites places", "Account", "About app"]
    
    var placesClient: GMSPlacesClient!
    
    var place: Places!
    
    var urlWeb = ""
    var urlTelNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapSettings()
        
        clusterFunc()
        
        createButtons()
        
        locationSettings()
        
        newObjectFunc()
        
        tableViewSettings()
        
        addFilterButton()
        
        getData()
        
        addMarkerInfoView()
    }
    
    //MARK: - View will appear
    
    override func viewWillAppear(_ animated: Bool) {
        getDataImage()
    }
    
    //MARK: - New objects
    
    func newObjectFunc() {
        
        placesArray = DataManager.shared.decodePlace()
        
        if placesArray.isEmpty {
            let firstPlace = Places(latitude: 53.873961, longitude: 27.499368, name: "Автосеть Уманская", placeID: "ChIJWaiUyAzQ20YRakPEJ7388gY", services: [.passengerTireFitting, .carMaintenance, .breakRepair, .oilChange, .seasonalTireStorage], favoriteStatus: false)
            let secondPlace = Places(latitude: 53.892702, longitude: 27.646785, name: "Автосеть Радиальная", placeID: "ChIJs9P1yW_O20YRTrwE7gQTBxo", services: [.passengerTireFitting, .truckTireFitting, .seasonalTireStorage], favoriteStatus: false)
            let thirdPlace = Places(latitude: 53.852154, longitude: 27.676753, name: "Автосеть Промышленная", placeID: "ChIJH09kZ3bS20YRFdu-9YawbMo", services: [.passengerTireFitting, .truckTireFitting, .seasonalTireStorage], favoriteStatus: false)
            
            placesArray.append(firstPlace)
            placesArray.append(secondPlace)
            placesArray.append(thirdPlace)
        }
        
        for i in placesArray {
            addMarker(i)
        }
    }
    
    //MARK: - Marker info view
    
    func addMarkerInfoView() {
        Bundle.main.loadNibNamed("MarkerInfoView", owner: self)
        view.addSubview(markerInfoView)
        markerInfoView.translatesAutoresizingMaskIntoConstraints = false
        hiddenMarkerInfoViewConstraint = markerInfoView.topAnchor.constraint(equalTo: view.bottomAnchor)
        showMarkerInfoViewConstraint = markerInfoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        
        NSLayoutConstraint.activate([
            hiddenMarkerInfoViewConstraint,
            markerInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            markerInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        markerInfoView.isUserInteractionEnabled = true
        markerInfoView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(webPressed(_:)))
        markerInfoView.webLabel.addGestureRecognizer(tapGesture)
        markerInfoView.webLabel.isUserInteractionEnabled = true
        tapGesture.delegate = self
        
        let telTapGesture = UITapGestureRecognizer(target: self, action: #selector(telPressed(_:)))
        markerInfoView.telLabel.addGestureRecognizer(telTapGesture)
        markerInfoView.telLabel.isUserInteractionEnabled = true
        telTapGesture.delegate = self
    }
    
    //MARK: - Filter
    
    func addFilterButton() {
        view.addSubview(filterButton)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filterButton.topAnchor.constraint(equalTo: showMenuButton.bottomAnchor, constant: 30),
            filterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            filterButton.widthAnchor.constraint(equalToConstant: 50),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        filterButton.backgroundColor = .white
        filterButton.alpha = 0.75
        filterButton.layer.cornerRadius = 25
        filterButton.setImage(UIImage(named: "filter"), for: .normal)
        filterButton.addTarget(self, action: #selector(goFilterVC(_:)), for: .primaryActionTriggered)
    }
    
    //MARK: - Filter func
    
    func filterFunc(service: Set<ProfServices>) {
        var placeId: Set<String> = []
        
        for place in placesArray {
            if service.isSubset(of: place.services) {
                placeId.insert(place.name)
            }
        }
        
        for marker in markerArray {
            if !placeId.contains(marker.title!) {
                marker.map = nil
            } else {
                marker.map = mapView
            }
        }
    }
    
    //MARK: - Get data functions
    
    func getData() {
        ref.getData(completion:  { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let allUsers = snapshot?.value as? Dictionary<String, Any> else {
                return
            }
            let users = allUsers.compactMap { k, v -> Person? in
                guard let values = v as? Dictionary<String, String>,
                      let username = values["username"],
                      let email = values["email"] else { return nil }
                if Auth.auth().currentUser?.uid == k {
                    self.nameLabel.text = "Hello, \(username)"
                    self.getDataImage()
                }
                let user = Person(uid: k, username: username, email: email)
                self.users.append(user)
                return Person(uid: k, username: username, email: email)
            }
            self.users = users
        })
    }
    
    func getDataImage() {
        let myImageReference = self.avatarsRef.child(Auth.auth().currentUser!.uid + ".jpg")
        myImageReference.getData(maxSize: 5 * 1024 * 1024) { data, error in
            if let error = error {
                print(error.localizedDescription)
                switch error {
                case let nsError as NSError where nsError.domain == StorageErrorDomain && nsError.code == StorageErrorCode.objectNotFound.rawValue:
                    self.avatarView.image = UIImage(named: "photo")
                default:
                    break
                }
            } else {
                let image = UIImage(data: data!)
                
                DispatchQueue.main.async {
                    self.avatarView.image = image
                }
            }
        }
    }
    
    //MARK: - Get directions
    
    func getDirections() {
        
        let currentLat = manager.location?.coordinate.latitude
        let currentLng = manager.location?.coordinate.longitude
        
        let destinationLat = place.latitude
        let destinationLng = place.longitude
        
        let currentLocation = "\(currentLat ?? 0),\(currentLng ?? 0)"
        let destinationLocation = "\(destinationLat),\(destinationLng)"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(currentLocation)&destination=\(destinationLocation)&mode=driving&key=AIzaSyAR3IFkBAeELyGIPbeS5cP3pgpRwAcQi1s"
        
        AF.request(url).responseDecodable(of: [Places].self) { (response) in
            guard let data = response.data else { return }
            
            do {
                let jsonData = try JSON(data: data)
                let routes = jsonData["routes"].arrayValue
                
                for route in routes {
                    let overview_polyline = route["overview_polyline"].dictionary
                    let points = overview_polyline?["points"]?.string
                    let path = GMSPath.init(fromEncodedPath: points ?? "")
                    self.polyline = GMSPolyline.init(path: path)
                    self.polyline.strokeColor = .orange
                    self.polyline.strokeWidth = 5
                    self.polyline.map = self.mapView
                }
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - Get distance and duration func
    
    func getDistance() {
        let currentLat = manager.location?.coordinate.latitude
        let currentLng = manager.location?.coordinate.longitude
        
        let destinationLat = place.latitude
        let destinationLng = place.longitude
        
        let currentLocation = "\(currentLat ?? 0),\(currentLng ?? 0)"
        let destinationLocation = "\(destinationLat),\(destinationLng)"
        
        let url = "https://maps.googleapis.com/maps/api/directions/json?origin=\(currentLocation)&destination=\(destinationLocation)&mode=driving&key=AIzaSyAR3IFkBAeELyGIPbeS5cP3pgpRwAcQi1s"
        
        AF.request(url).responseDecodable(of: [Places].self) { (response) in
            guard let data = response.data else { return }
            
            do {
                let jsonData = try JSON(data: data)
                let routes = jsonData["routes"].arrayValue
                
                for route in routes {
                    
                    let legs = route["legs"].arrayValue
                    for i in legs {
                        let distance = i["distance"].dictionary
                        let distanceText = distance?["text"]?.string
                        
                        let duration = i["duration"].dictionary
                        let durationText = duration?["text"]?.string
                        
                        self.markerInfoView.distanceLabel.text = "\(distanceText ?? "") - \(durationText ?? "")"
                    }
                }
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    //MARK: - Get info about place
    
    func getInfoAboutPlace(placeID: String, coordinate: CLLocationCoordinate2D) {
        placesClient = GMSPlacesClient.shared()
        
        let fields: GMSPlaceField = [.name, .formattedAddress, .phoneNumber, .rating, .website, .photos]
        placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil) { place, error in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            if let place = place {
                self.getDistance()
                
                self.markerInfoView.nameLabel.text = place.name
                
                self.markerInfoView.addressLabel.text = place.formattedAddress
                
                self.urlTelNumber = place.phoneNumber ?? ""
                self.markerInfoView.telLabel.text = "📞"
                
                self.markerInfoView.ratingLabel.text = "⭐️ \(String(place.rating))"
                
                let url = place.website
                self.urlWeb = url?.absoluteString ?? ""
                self.markerInfoView.webLabel.text = "🌍"
                
                let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]
                self.placesClient?.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
                    if let error = error {
                        print("Error loading photo metadata: \(error.localizedDescription)")
                        return
                    } else {
                        self.markerInfoView.photoImage.image = photo;
                    }
                })
            }
        }
    }
    
    //MARK: - Location Settings
    
    func locationSettings() {
        //        manager.desiredAccuracy = kCLLocationAccuracyBest
        //        manager.requestWhenInUseAuthorization()
        //        manager.distanceFilter = 50
        //        manager.startUpdatingLocation()
        
        manager.delegate = self
        if CLLocationManager.locationServicesEnabled() {
            manager.requestLocation()
        } else {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    //MARK: - Create buttons
    
    func buttonSettings(button: UIButton, previousView: UIView, nameImage: String, constant: CGFloat) {
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 56),
            button.heightAnchor.constraint(equalToConstant: 56),
            button.bottomAnchor.constraint(equalTo: previousView.bottomAnchor, constant: constant),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        button.setImage(UIImage(named: nameImage), for: .normal)
        button.layer.cornerRadius = 28
    }
    
    func createButtons() {
        
        buttonSettings(button: changeStyleButton, previousView: view, nameImage: "sun", constant: -112)
        buttonSettings(button: minusZoomButton, previousView: changeStyleButton, nameImage: "minus", constant: -69)
        buttonSettings(button: plusZoomButton, previousView: minusZoomButton, nameImage: "plus", constant: -69)
        buttonSettings(button: trafficButoon, previousView: plusZoomButton, nameImage: "traffic", constant: -69)
        
        changeStyleButton.addTarget(self, action: #selector(styleButtonTapped(_:)), for: .primaryActionTriggered)
        minusZoomButton.addTarget(self, action: #selector(minusOneZoom(_:)), for: .primaryActionTriggered)
        plusZoomButton.addTarget(self, action: #selector(plusOneZoom(_:)), for: .primaryActionTriggered)
        trafficButoon.addTarget(self, action: #selector(traffic(_:)), for: .primaryActionTriggered)
    }
    
    //MARK: - Button actions
    
    @objc func styleButtonTapped(_ sender: UIButton) {
        if lightStyle {
            style(for: "darkStyle", withExtension: ".json")
            changeStyleButton.setImage(UIImage(named: "sun"), for: .normal)
            lightStyle.toggle()
            clearView.backgroundColor = .systemGray6
            if lightStyle == false && hiddenMenuConstraint.isActive == true {
                showMenuButton.backgroundColor = .white
                showMenuButton.alpha = 0.75
                filterButton.setImage(UIImage(named: "filter"), for: .normal)
                filterButton.backgroundColor = .white
                filterButton.alpha = 0.75
            }
        } else {
            style(for: "lightStyle", withExtension: ".json")
            changeStyleButton.setImage(UIImage(named: "dark"), for: .normal)
            lightStyle.toggle()
            clearView.backgroundColor = .systemGray
            showMenuButton.backgroundColor = .systemGray3
            showMenuButton.alpha = 1
            filterButton.setImage(UIImage(named: "blackFilter"), for: .normal)
            filterButton.backgroundColor = .systemGray3
            filterButton.alpha = 1
        }
    }
    
    @objc func plusOneZoom(_ sender: UIButton) {
        let zoom = GMSCameraUpdate.zoomIn()
        mapView.animate(with: zoom)
    }
    
    @objc func minusOneZoom(_ sender: UIButton) {
        let zoom = GMSCameraUpdate.zoomOut()
        mapView.animate(with: zoom)
    }
    
    @objc func traffic(_ sender: UIButton) {
        switch trafficFlag {
        case false:
            trafficFlag.toggle()
            mapView.isTrafficEnabled = true
        case true:
            trafficFlag.toggle()
            mapView.isTrafficEnabled = false
        }
    }
    
    @objc func showTableView(_ sender: UIButton) {
        switch showTableView {
        case false:
            showMenuFunc()
        case true:
            hideMenuFunc()
        }
    }
    
    @objc func signOut(_ sender: UIButton) {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to log out?", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Yes, logout", style: .destructive) { _ in
            try? Auth.auth().signOut()
            if Auth.auth().currentUser == nil {
                let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
                self.navigationController?.setViewControllers([loginVC], animated: true)
            }
        }
        let secondAction = UIAlertAction(title: "Cancel", style: .default) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(action)
        alert.addAction(secondAction)
        present(alert, animated: true)
    }
    
    @objc func goFilterVC(_ sender: UIButton) {
        let newVC = (storyboard?.instantiateViewController(withIdentifier: "filterViewController")) as! FilterViewController
        present(newVC, animated: true)
        
        newVC.delegate = self
    }
    
    @objc func webPressed(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Do you want to go to this site: \(urlWeb)?", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Yes", style: .default) { _ in
            if let url = URL(string: self.urlWeb) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        let secondAction = UIAlertAction(title: "No", style: .cancel) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(action)
        alert.addAction(secondAction)
        present(alert, animated: true)
    }
    
    @objc func telPressed(_ sender: UITapGestureRecognizer) {
        urlTelNumber = urlTelNumber.components(separatedBy: "-").joined(separator: "")
        urlTelNumber = urlTelNumber.components(separatedBy: .whitespaces).joined(separator: "")
        
        if let url = URL(string: "tel://\(urlTelNumber)") {
            UIApplication.shared.open(url as URL)
        }
    }
    
    //MARK: - Style
    
    func style(for resource: String, withExtension: String) {
        do {
            if let styleURL = Bundle.main.url(forResource: resource, withExtension: withExtension) {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
    //MARK: - Map settings
    
    func mapSettings() {
        let camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: manager.location?.coordinate.latitude ?? 0, longitude: manager.location?.coordinate.longitude ?? 0), zoom: 5)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.isMyLocationEnabled = true
        style(for: "darkStyle", withExtension: ".json")
        view = mapView
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        mapView.delegate = self
        
        let zoom = GMSCameraUpdate.zoom(to: 10.7)
        mapView.animate(with: zoom)
    }
    
    //MARK: - Cluster markers
    
    func clusterFunc() {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView,
                                                 clusterIconGenerator: iconGenerator)
        cluster = GMUClusterManager(map: mapView, algorithm: algorithm,
                                    renderer: renderer)
        cluster.setMapDelegate(self)
    }
    
    //MARK: - Add marker
    
    func addMarker(_ object: Places) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: object.latitude, longitude: object.longitude)
        marker.map = mapView
        marker.title = object.name
        marker.userData = object
        cluster.add(marker)
        cluster.cluster()
        markerArray.append(marker)
    }
}

extension MapViewController: FilterViewControllerDelegate {
    
    func filterMap(with set: Set<ProfServices>) {
        filterFunc(service: set)
    }
}

extension MapViewController: MarkerInfoViewDelegate {
    
    func favoritesPlaces(_ sender: UIButton) {
        
        placesArray.removeAll { place in
            place.name == self.place.name
        }
        
        place.favoriteStatus.toggle()
        
        placesArray.append(place)
        
        DataManager.shared.encodePlace(type: placesArray)
        
        if place.favoriteStatus {
            sender.setImage(UIImage(named: "heartRed"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "heartClear"), for: .normal)
        }
    }
}
