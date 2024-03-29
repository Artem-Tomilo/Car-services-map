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

final class MapViewController: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet var markerInfoView: MarkerInfoView!
    
    //MARK: - properties
    
    var mapView = GMSMapView()
    let someView = UIView()
    let viewForUserData = UIView()
    let avatarView = UIImageView()
    let clearView = UIView()
    let tableView = UITableView()
    let nameLabel = UILabel()
    
    let hidingButton = UIButton()
    private let locationButton = UIButton()
    private let changeStyleButton = UIButton()
    private let minusZoomButton = UIButton()
    private let plusZoomButton = UIButton()
    let showMenuButton = UIButton()
    let signOutButton = UIButton()
    let filterButton = UIButton()
    private let trafficButoon = UIButton()
    let allPlacesButton = UIButton()
    
    var showMenuConstraint = NSLayoutConstraint()
    var hiddenMenuConstraint = NSLayoutConstraint()
    var showClearViewConstraint = NSLayoutConstraint()
    var hiddenClearViewConstraint = NSLayoutConstraint()
    var showMarkerInfoViewConstraint = NSLayoutConstraint()
    var hiddenMarkerInfoViewConstraint = NSLayoutConstraint()
    var hidingButtonDownConstraint = NSLayoutConstraint()
    var hidingButtonUpConstraint = NSLayoutConstraint()
    
    private var showAllButtons = false
    var lightStyle = false
    var showTableView = false
    private var trafficFlag = false
    private var showAllPlacesOnMap = false
    
    private let ref = Database.database().reference().child("users")
    private let storage = Storage.storage()
    private lazy var avatarsRef = storage.reference().child("avatars/")
    private let placesRef = Database.database().reference().child("places")
    
    var placesArray: [Places] = []
    private var users: [Person] = []
    var markerArray: [GMSMarker] = []
    
    private let manager = CLLocationManager()
    
    private var placesClient = GMSPlacesClient()
    
    private var resultsViewController: GMSAutocompleteResultsViewController?
    
    var searchController: UISearchController?
    
    var polyline = GMSPolyline()
    
    let listTableViewMenu = ["Advanced filter", "My favorites places", "Account", "About app"]
    
    var place: Places?
    
    private var urlWeb = ""
    private var urlTelNumber = ""
    
    //MARK: - View did load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapSettings()
        
        searchControllerSettings()
        
        tableViewSettings()
        
        configureMarkerInfoView()
        
        createButtons()
        
        configureFilterButtonAndAllPlacesButton()
        
        getPersonData()
    }
    
    //MARK: - View will appear
    
    override func viewWillAppear(_ animated: Bool) {
        getDataImage()
        locationManagerDidChangeAuthorization(manager)
        locationSettings()
    }
    
    //MARK: - Location Settings
    
    private func locationSettings() {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 50
        manager.startUpdatingLocation()
        
        manager.delegate = self
    }
    
    //MARK: - Map settings
    
    private func mapSettings() {
        let camera = GMSCameraPosition(latitude: 53.896369, longitude: 27.551483, zoom: 10)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        
        view.addSubview(mapView)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.settings.compassButton = true
        mapView.isMyLocationEnabled = true
        
        NSLayoutConstraint.activate([
            mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
        
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        style(for: "darkStyle", withExtension: ".json")
        
        mapView.delegate = self
    }
    
    //MARK: - Search controller
    
    private func searchControllerSettings() {
        resultsViewController = GMSAutocompleteResultsViewController()
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        let searchBar = searchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = searchController?.searchBar
        
        definesPresentationContext = true
        searchController?.hidesNavigationBarDuringPresentation = false
        resultsViewController?.delegate = self
    }
    
    //MARK: - Marker info view
    
    func configureMarkerInfoView() {
        Bundle.main.loadNibNamed("MarkerInfoView", owner: self)
        
        view.addSubview(markerInfoView)
        
        markerInfoView.translatesAutoresizingMaskIntoConstraints = false
        markerInfoView.isUserInteractionEnabled = true
        
        hiddenMarkerInfoViewConstraint = markerInfoView.topAnchor.constraint(equalTo: view.bottomAnchor)
        showMarkerInfoViewConstraint = markerInfoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            hiddenMarkerInfoViewConstraint,
            markerInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            markerInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
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
    
    //MARK: - Create buttons
    
    private func buttonSettings(button: UIButton, previousView: UIView, nameImage: String, constant: CGFloat) {
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        
        button.backgroundColor = .white
        button.setImage(UIImage(named: nameImage), for: .normal)
        button.layer.cornerRadius = 25
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 50),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        
        if button == hidingButton {
            hidingButtonDownConstraint = button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50)
            hidingButtonUpConstraint = button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(markerInfoView.frame.height + 20))
            NSLayoutConstraint.activate([
                hidingButtonDownConstraint
            ])
        } else {
            NSLayoutConstraint.activate([
                button.bottomAnchor.constraint(equalTo: previousView.bottomAnchor, constant: constant),
            ])
        }
    }
    
    private func createButtons() {
        
        buttonSettings(button: hidingButton, previousView: view, nameImage: "dot", constant: -50)
        buttonSettings(button: locationButton, previousView: hidingButton, nameImage: "location", constant: -60)
        buttonSettings(button: changeStyleButton, previousView: locationButton, nameImage: "sun", constant: -60)
        buttonSettings(button: minusZoomButton, previousView: changeStyleButton, nameImage: "minus", constant: -60)
        buttonSettings(button: plusZoomButton, previousView: minusZoomButton, nameImage: "plus", constant: -60)
        buttonSettings(button: trafficButoon, previousView: plusZoomButton, nameImage: "traffic", constant: -60)
        
        hidingButton.addTarget(self, action: #selector(hideOrShowAllButtons(_:)), for: .primaryActionTriggered)
        locationButton.addTarget(self, action: #selector(userLocation(_:)), for: .primaryActionTriggered)
        changeStyleButton.addTarget(self, action: #selector(styleButtonTapped(_:)), for: .primaryActionTriggered)
        minusZoomButton.addTarget(self, action: #selector(minusOneZoom(_:)), for: .primaryActionTriggered)
        plusZoomButton.addTarget(self, action: #selector(plusOneZoom(_:)), for: .primaryActionTriggered)
        trafficButoon.addTarget(self, action: #selector(showAndHideTraffic(_:)), for: .primaryActionTriggered)
        
        hidingButton.isHidden = false
    }
    
    //MARK: - AllPlacesButton and FilterButton config
    
    private func configureFilterButtonAndAllPlacesButton() {
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
        
        view.addSubview(allPlacesButton)
        allPlacesButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            allPlacesButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            allPlacesButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            allPlacesButton.widthAnchor.constraint(equalToConstant: 50),
            allPlacesButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        allPlacesButton.setImage(UIImage(named: "flag"), for: .normal)
        allPlacesButton.backgroundColor = .white
        allPlacesButton.alpha = 0.75
        allPlacesButton.layer.cornerRadius = 25
        allPlacesButton.addTarget(self, action: #selector(showAndHideAllPlaces(_:)), for: .primaryActionTriggered)
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
    
    //MARK: - Get objects data
    
    func getObjectsData(radius: Int?) {
        
        placesRef.getData { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let allPlaces = snapshot?.value as? Dictionary<String, Any> else {
                return
            }
            let _ = allPlaces.compactMap { k, v -> Places? in
                guard let values = v as? Dictionary<String, Any>,
                      let coordinates = values["coordinates"] as? Dictionary<String, Double>,
                      let latitude = coordinates["latitude"],
                      let longitude = coordinates["longitude"],
                      let name = values["name"] as? String,
                      let favoriteStatus = values["favoriteStatus"] as? Bool,
                      let services = values["services"] as? Array<String> else { return nil }
                
                var setServices: Set<ProfServices> = []
                for service in ProfServices.allCases {
                    for i in services {
                        if service.title == i {
                            setServices.insert(service)
                        }
                    }
                }
                let place = Places(latitude: latitude, longitude: longitude, name: name, placeID: k, services: setServices, favoriteStatus: favoriteStatus)
                self.placesArray.append(place)
                return place
            }
            for i in self.placesArray {
                self.getDistance(place: i, meters: radius)
            }
        }
    }
    
    
    //MARK: - Get person data functions
    
    private func getPersonData() {
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
    
    private func getDataImage() {
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
        
        guard let place = place else { return }
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
    
    private func getDistance(place: Places, meters: Int?) {
        let currentLat = manager.location?.coordinate.latitude
        let currentLng = manager.location?.coordinate.longitude
        
        let destinationLat = place.latitude
        let destinationLng = place.longitude
        
        let currentLocation = "\(currentLat ?? 53.896369),\(currentLng ?? 27.551483)"
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
                        let distanceValue  = distance?["value"]?.int
                        
                        if distanceValue! <= meters ?? 40000 {
                            if !self.markerArray.isEmpty {
                                if !self.markerArray.contains(where: { marker in
                                    marker.position.latitude == place.latitude && marker.position.longitude == place.longitude
                                }) {
                                    self.addMarkerOnTheMap(place)
                                }
                            } else {
                                self.addMarkerOnTheMap(place)
                            }
                        }
                        
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
                self.getDistance(place: self.place!, meters: nil)
                
                self.markerInfoView.nameLabel.text = place.name
                
                self.markerInfoView.addressLabel.text = place.formattedAddress
                
                self.urlTelNumber = place.phoneNumber ?? ""
                self.markerInfoView.telLabel.text = "📞"
                
                self.markerInfoView.ratingLabel.text = "⭐️ \(String(place.rating))"
                
                let url = place.website
                self.urlWeb = url?.absoluteString ?? ""
                self.markerInfoView.webLabel.text = "🌍"
                
                let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]
                self.placesClient.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
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
    
    //MARK: - Style
    
    private func style(for resource: String, withExtension: String) {
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
    
    //MARK: - Add marker
    
    private func addMarkerOnTheMap(_ object: Places) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: object.latitude, longitude: object.longitude)
        marker.map = mapView
        marker.title = object.name
        marker.userData = object
        markerArray.append(marker)
    }
    
    //MARK: - Hide and show all buttons
    
    private func hideButtons() {
        locationButton.isHidden = true
        changeStyleButton.isHidden = true
        minusZoomButton.isHidden = true
        plusZoomButton.isHidden = true
        trafficButoon.isHidden = true
    }
    
    private func showButtons() {
        locationButton.isHidden = false
        changeStyleButton.isHidden = false
        minusZoomButton.isHidden = false
        plusZoomButton.isHidden = false
        trafficButoon.isHidden = false
    }
    
    //MARK: - Button actions
    
    @objc func hideOrShowAllButtons(_ sender: UIButton) {
        switch showAllButtons {
        case false:
            showAllButtons.toggle()
            showButtons()
        case true:
            showAllButtons.toggle()
            hideButtons()
        }
    }
    
    @objc func userLocation(_ sender: UIButton) {
        let camera = GMSCameraPosition(target: manager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 53.896369, longitude: 27.551483), zoom: 12)
        mapView.animate(to: camera)
    }
    
    @objc func styleButtonTapped(_ sender: UIButton) {
        if lightStyle {
            style(for: "darkStyle", withExtension: ".json")
            changeStyleButton.setImage(UIImage(named: "sun"), for: .normal)
            lightStyle.toggle()
            clearView.backgroundColor = .systemGray6
            locationButton.setImage(UIImage(named: "location"), for: .normal)
            if lightStyle == false && hiddenMenuConstraint.isActive == true {
                showMenuButton.backgroundColor = .white
                showMenuButton.alpha = 0.75
                filterButton.setImage(UIImage(named: "filter"), for: .normal)
                filterButton.backgroundColor = .white
                filterButton.alpha = 0.75
                allPlacesButton.backgroundColor = .white
                allPlacesButton.alpha = 0.75
            }
        } else {
            style(for: "lightStyle", withExtension: ".json")
            locationButton.setImage(UIImage(named: "darkLocation"), for: .normal)
            changeStyleButton.setImage(UIImage(named: "dark"), for: .normal)
            lightStyle.toggle()
            clearView.backgroundColor = .systemGray
            showMenuButton.backgroundColor = .systemGray3
            showMenuButton.alpha = 1
            filterButton.setImage(UIImage(named: "darkFilter"), for: .normal)
            filterButton.backgroundColor = .systemGray3
            filterButton.alpha = 1
            allPlacesButton.backgroundColor = .systemGray3
            allPlacesButton.alpha = 1
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
    
    @objc func showAndHideTraffic(_ sender: UIButton) {
        switch trafficFlag {
        case false:
            trafficFlag.toggle()
            mapView.isTrafficEnabled = true
        case true:
            trafficFlag.toggle()
            mapView.isTrafficEnabled = false
        }
    }
    
    @objc func showAndHideTableView(_ sender: UIButton) {
        switch showTableView {
        case false:
            if showAllButtons {
                showAllButtons.toggle()
            }
            hideButtons()
            allPlacesButton.isHidden = true
            hidingButton.isHidden = true
            navigationController?.setNavigationBarHidden(true, animated: true)
            showMenuFunc()
            mapView.selectedMarker = nil
        case true:
            allPlacesButton.isHidden = false
            hidingButton.isHidden = false
            hideMenuFunc()
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    @objc func signOutFromAcc(_ sender: UIButton) {
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
    
    @objc func showAndHideAllPlaces(_ sender: UIButton) {
        markerArray.removeAll()
        mapView.clear()
        
        switch showAllPlacesOnMap {
        case false:
            for i in placesArray {
                addMarkerOnTheMap(i)
            }
        case true:
            for i in placesArray {
                getDistance(place: i, meters: 7000)
            }
        }
        
        showAllPlacesOnMap.toggle()
    }
}
