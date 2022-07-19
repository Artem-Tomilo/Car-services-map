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
    
    let hidingButton = UIButton()
    let locationButton = UIButton()
    let changeStyleButton = UIButton()
    let minusZoomButton = UIButton()
    let plusZoomButton = UIButton()
    let showMenuButton = UIButton()
    let signOutButton = UIButton()
    let filterButton = UIButton()
    let trafficButoon = UIButton()
    let allPlacesButton = UIButton()
    
    var showMenuConstraint: NSLayoutConstraint!
    var hiddenMenuConstraint: NSLayoutConstraint!
    var showClearViewConstraint: NSLayoutConstraint!
    var hiddenClearViewConstraint: NSLayoutConstraint!
    var showMarkerInfoViewConstraint: NSLayoutConstraint!
    var hiddenMarkerInfoViewConstraint: NSLayoutConstraint!
    var hidingButtonDownConstraint: NSLayoutConstraint!
    var hidingButtonUpConstraint: NSLayoutConstraint!
    
    var showAllButtons = false
    var lightStyle = false
    var showTableView = false
    var trafficFlag = false
    var showAllPlacesOnMap = false
    
    let ref = Database.database().reference().child("users")
    let storage = Storage.storage()
    lazy var avatarsRef = storage.reference().child("avatars/")
    let placesRef = Database.database().reference().child("places")
    
    var placesArray: [Places] = []
    var users: [Person] = []
    var markerArray: [GMSMarker] = []
    
    let manager = CLLocationManager()
    
    var polyline = GMSPolyline()
    
    let listTableViewMenu = ["Advanced filter", "My favorites places", "Account", "About app"]
    
    var placesClient: GMSPlacesClient!
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    
    var searchController: UISearchController?
    
    var place: Places!
    
    var urlWeb = ""
    var urlTelNumber = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapSettings()
        
        searchControllerSettings()
        
        tableViewSettings()
        
        addMarkerInfoView()
        
        createButtons()
        
        addFilterButtonAndAllPlacesButton()
        
        newObjectFunc()
        
        locationSettings()
        
        getData()
    }
    
    //MARK: - View will appear
    
    override func viewWillAppear(_ animated: Bool) {
        getDataImage()
    }
    
    //MARK: - Map settings
    
    func mapSettings() {
        // settings for simulator
        
        //        let camera = GMSCameraPosition(latitude: 53.896369, longitude: 27.551483, zoom: 5)
        //        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        //        view = mapView
        
        //setiings for real device
        
        let camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: manager.location?.coordinate.latitude ?? 0, longitude: manager.location?.coordinate.longitude ?? 0), zoom: 5)
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
        
        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        mapView.settings.compassButton = true
        mapView.isMyLocationEnabled = true
        style(for: "darkStyle", withExtension: ".json")
        
        mapView.delegate = self
        
        let zoom = GMSCameraUpdate.zoom(to: 13)
        mapView.animate(with: zoom)
    }
    
    //MARK: - Search controller
    
    func searchControllerSettings() {
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
    
    //MARK: - Create buttons
    
    func buttonSettings(button: UIButton, previousView: UIView, nameImage: String, constant: CGFloat) {
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
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
        
        button.setImage(UIImage(named: nameImage), for: .normal)
        button.layer.cornerRadius = 25
        button.isHidden = true
    }
    
    func createButtons() {
        
        buttonSettings(button: hidingButton, previousView: view, nameImage: "dot", constant: -50)
        buttonSettings(button: locationButton, previousView: hidingButton, nameImage: "location", constant: -60)
        buttonSettings(button: changeStyleButton, previousView: locationButton, nameImage: "sun", constant: -60)
        buttonSettings(button: minusZoomButton, previousView: changeStyleButton, nameImage: "minus", constant: -60)
        buttonSettings(button: plusZoomButton, previousView: minusZoomButton, nameImage: "plus", constant: -60)
        buttonSettings(button: trafficButoon, previousView: plusZoomButton, nameImage: "traffic", constant: -60)
        
        hidingButton.addTarget(self, action: #selector(hideOrShowAllButtons(_:)), for: .primaryActionTriggered)
        locationButton.addTarget(self, action: #selector(location(_:)), for: .primaryActionTriggered)
        changeStyleButton.addTarget(self, action: #selector(styleButtonTapped(_:)), for: .primaryActionTriggered)
        minusZoomButton.addTarget(self, action: #selector(minusOneZoom(_:)), for: .primaryActionTriggered)
        plusZoomButton.addTarget(self, action: #selector(plusOneZoom(_:)), for: .primaryActionTriggered)
        trafficButoon.addTarget(self, action: #selector(traffic(_:)), for: .primaryActionTriggered)
        
        hidingButton.isHidden = false
    }
    
    //MARK: - AllPlacesButton and FilterButton settings
    
    func addFilterButtonAndAllPlacesButton() {
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
        allPlacesButton.setImage(UIImage(named: ""), for: .normal)
        allPlacesButton.backgroundColor = .white
        allPlacesButton.alpha = 0.75
        allPlacesButton.layer.cornerRadius = 25
        allPlacesButton.addTarget(self, action: #selector(showAllPlaces(_:)), for: .primaryActionTriggered)
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
    
    //MARK: - New objects
    
    func newObjectFunc() {
        
        placesArray = DataManager.shared.decodePlace()
        
        if placesArray.isEmpty {
            let place1 = Places(latitude: 53.873981, longitude: 27.49935499999999, name: "Автосеть Уманская", placeID: "ChIJWaiUyAzQ20YRakPEJ7388gY", services: [.passengerTireFitting, .carMaintenance, .breakRepair, .oilChange, .seasonalTireStorage], favoriteStatus: false)
            let place2 = Places(latitude: 53.89280669999999, longitude: 27.6465287, name: "Автосеть Радиальная", placeID: "ChIJs9P1yW_O20YRTrwE7gQTBxo", services: [.passengerTireFitting, .truckTireFitting, .seasonalTireStorage], favoriteStatus: false)
            let place3 = Places(latitude: 53.8521044, longitude: 27.67671959999999, name: "Автосеть Промышленная", placeID: "ChIJH09kZ3bS20YRFdu-9YawbMo", services: [.passengerTireFitting, .truckTireFitting, .seasonalTireStorage], favoriteStatus: false)
            let place4 = Places(latitude: 53.906886, longitude: 27.681267, name: "Колесоплюс Карвата", placeID: "ChIJR6A5zsbP20YR8uL7h0_KrTI", services: [.passengerTireFitting, .truckTireFitting], favoriteStatus: false)
            let place5 = Places(latitude: 53.8791045, longitude: 27.4105503, name: "Колесоплюс Монтажников", placeID: "ChIJDXbj-f3a20YRreKax2GAGXQ", services: [.passengerTireFitting, .truckTireFitting], favoriteStatus: false)
            let place6 = Places(latitude: 53.8451518, longitude: 27.4450747, name: "ГранатАвто М", placeID: "ChIJPUWJBnTa20YRdmFRFCbTnDk", services: [.passengerTireFitting, .carMaintenance, .breakRepair, .oilChange], favoriteStatus: false)
            let place7 = Places(latitude: 53.83351829999999, longitude: 27.5544026, name: "СТО РИМБАТ", placeID: "ChIJ5wuw5V_R20YRAXFgmO_lLks", services: [.passengerTireFitting, .carMaintenance, .breakRepair, .oilChange], favoriteStatus: false)
            let place8 = Places(latitude: 53.9037807, longitude: 27.4132021, name: "СТО TOP CRAFT", placeID: "ChIJseY62Rvb20YRPa-3jDm1tfI", services: [.passengerTireFitting, .carMaintenance, .breakRepair, .oilChange, .carWash], favoriteStatus: false)
            let place9 = Places(latitude: 53.8955371, longitude: 27.6944475, name: "СТО Альтернатива", placeID: "ChIJZbQQqzLM20YRuC914Nc-bYk", services: [.carMaintenance, .breakRepair, .oilChange], favoriteStatus: false)
            let place10 = Places(latitude: 53.95536240000001, longitude: 27.7096865, name: "СТО WDrive Уручье Автосервис", placeID: "ChIJ03MWqSvJ20YRYFScsp2wx9U", services: [.carMaintenance, .breakRepair, .oilChange], favoriteStatus: false)
            let place11 = Places(latitude: 53.9155623, longitude: 27.68796459999999, name: "СТО Торсион", placeID: "ChIJla9umJ7O20YRqYpm9ZkP4HY", services: [.carMaintenance, .breakRepair, .oilChange], favoriteStatus: false)
            let place12 = Places(latitude: 53.8860888, longitude: 27.63263389999999, name: "СТО АНДРИВАН", placeID: "ChIJDyQlmzXO20YRN5Q5jGjQ9oM", services: [.carMaintenance, .breakRepair, .oilChange], favoriteStatus: false)
            let place13 = Places(latitude: 53.8413836, longitude: 27.4840469, name: "Шиномонтаж на Ландера", placeID: "ChIJtX0Pc5LQ20YRFwlxJDKoX3c", services: [.passengerTireFitting], favoriteStatus: false)
            let place14 = Places(latitude: 53.887187, longitude: 27.480277, name: "Шиномонтаж Логово", placeID: "ChIJP9qam73b20YRC2yY6uk3LSQ", services: [.passengerTireFitting], favoriteStatus: false)
            let place15 = Places(latitude: 53.8308639, longitude: 27.60580819999999, name: "Шинный центр Дискол-Плюс", placeID: "ChIJaf4LySnS20YRHtYqSwG7ltg", services: [.passengerTireFitting, .truckTireFitting], favoriteStatus: false)
            let place16 = Places(latitude: 53.93115599999999, longitude: 27.7030728, name: "4 БОКСА", placeID: "ChIJldITMq_O20YRExnWWMFrZ_E", services: [.passengerTireFitting, .truckTireFitting], favoriteStatus: false)
            let place17 = Places(latitude: 53.91642170000001, longitude: 27.5215486, name: "TYREPLUS Тимирязева", placeID: "ChIJn9jdN2fF20YRAnA5gvyHj8s", services: [.passengerTireFitting, .carMaintenance, .breakRepair, .oilChange, .seasonalTireStorage], favoriteStatus: false)
            let place18 = Places(latitude: 53.878782, longitude: 27.59434599999999, name: "TYREPLUS Велосипедный пер", placeID: "ChIJlXTwHCbO20YRDHY8tnkcxQ0", services: [.passengerTireFitting, .carMaintenance, .breakRepair, .oilChange, .seasonalTireStorage], favoriteStatus: false)
            let place19 = Places(latitude: 53.9583153, longitude: 27.6322779, name: "TYREPLUS Логойский тракт", placeID: "ChIJH6SftczI20YR0iYkdN24IBM", services: [.passengerTireFitting, .carMaintenance, .breakRepair, .oilChange, .seasonalTireStorage], favoriteStatus: false)
            let place20 = Places(latitude: 53.87338769999999, longitude: 27.5037031, name: "Склад Шин - Сезонное хранение шин и велосипедов", placeID: "ChIJkwzZ_HzP20YRp_g0HE_4zTM", services: [.seasonalTireStorage], favoriteStatus: false)
            let place21 = Places(latitude: 53.9086805, longitude: 27.4286835, name: "Автомойка GT", placeID: "ChIJExhXeZPb20YRRFTN9YrwzX8", services: [.carWash], favoriteStatus: false)
            let place22 = Places(latitude: 53.9104957, longitude: 27.5042457, name: "Сивый мерин. Автомойка. Химчистка. Полировка.", placeID: "ChIJb5kI2ETF20YRdUxqBk55iqk", services: [.carWash], favoriteStatus: false)
            let place23 = Places(latitude: 53.93014409999999, longitude: 27.65915429999999, name: "Автомойка CleanAuto Скорины", placeID: "ChIJLb_HJMLO20YRGiu58SrsHeI", services: [.carWash], favoriteStatus: false)
            let place24 = Places(latitude: 53.8724853, longitude: 27.5604165, name: "АвтоСуперКомплекс", placeID: "ChIJP5a1rS3Q20YRd_sQx-LV9JI", services: [.carWash], favoriteStatus: false)
            let place25 = Places(latitude: 53.865666, longitude: 27.42612059999999, name: "Авто SPA. Автомойка 24/7", placeID: "ChIJqxQYKV_a20YR43Uvp38hctc", services: [.carWash], favoriteStatus: false)
            let place26 = Places(latitude: 53.9207325, longitude: 27.56555239999999, name: "Аквалаб", placeID: "ChIJz871k2zP20YRExXKzYWgg7s", services: [.carWash], favoriteStatus: false)
            let place27 = Places(latitude: 53.8647436, longitude: 27.5033956, name: "Техцентр BMW - ЗауберАвто", placeID: "ChIJB6EvRxHQ20YRgwztX_ZO_Pg", services: [.passengerTireFitting, .carMaintenance, .breakRepair, .oilChange], favoriteStatus: false)
            let place28 = Places(latitude: 53.8857481, longitude: 27.5009273, name: "Ручная автомойка МойCAR", placeID: "ChIJI2CjmwfQ20YRyahozRZecfo", services: [.carWash], favoriteStatus: false)
            let place29 = Places(latitude: 53.8642668, longitude: 27.6506701, name: "Автомойка Шиномонтаж Perfect Look Service & Wash", placeID: "ChIJ1RR8OPnN20YRg7tYHQdY_CU", services: [.passengerTireFitting, .carWash], favoriteStatus: false)
            let place30 = Places(latitude: 53.9590835, longitude: 27.70116419999999, name: "Шиномонтаж Профитрак", placeID: "ChIJH35KqzrJ20YRHN2n2arbPhY", services: [.passengerTireFitting, .truckTireFitting], favoriteStatus: false)
            
            placesArray.append(place1)
            placesArray.append(place2)
            placesArray.append(place3)
            placesArray.append(place4)
            placesArray.append(place5)
            placesArray.append(place6)
            placesArray.append(place7)
            placesArray.append(place8)
            placesArray.append(place9)
            placesArray.append(place10)
            placesArray.append(place11)
            placesArray.append(place12)
            placesArray.append(place13)
            placesArray.append(place14)
            placesArray.append(place15)
            placesArray.append(place16)
            placesArray.append(place17)
            placesArray.append(place18)
            placesArray.append(place19)
            placesArray.append(place20)
            placesArray.append(place21)
            placesArray.append(place22)
            placesArray.append(place23)
            placesArray.append(place24)
            placesArray.append(place25)
            placesArray.append(place26)
            placesArray.append(place27)
            placesArray.append(place28)
            placesArray.append(place29)
            placesArray.append(place30)
        }
        
        for i in placesArray {
            getDistance(place: i, meters: 7000)
        }
        
        //        for i in placesArray {
        //            for m in ProfServices.allCases {
        //                if i.services.contains(m) {
        //                    var ser: [String] = []
        //                    ser.append(m.title)
        //                    for s in ser {
        //                        self.placesRef.child(i.placeID).setValue([
        //                            "name": i.name,
        //                            "coordinates": ["latitude": i.latitude, "longitude": i.longitude],
        //                            "favoriteStatus": i.favoriteStatus,
        //                            "services": ["\(m.rawValue)" : s]
        //                        ])
        //                    }
        //                }
        //            }
        //        }
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
    
    func getDistance(place: Places, meters: Int?) {
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
                        let distanceValue  = distance?["value"]?.int
                        
                        if distanceValue! <= meters ?? 40000 {
                            if !self.markerArray.isEmpty {
                                if !self.markerArray.contains(where: { marker in
                                    marker.position.latitude == place.latitude
                                }) {
                                    self.addMarker(place)
                                }
                            } else {
                                self.addMarker(place)
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
                self.getDistance(place: self.place, meters: nil)
                
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
    
    //MARK: - Button actions
    
    @objc func hideOrShowAllButtons(_ sender: UIButton) {
        switch showAllButtons {
        case false:
            showAllButtons.toggle()
            locationButton.isHidden = false
            changeStyleButton.isHidden = false
            minusZoomButton.isHidden = false
            plusZoomButton.isHidden = false
            trafficButoon.isHidden = false
        case true:
            showAllButtons.toggle()
            locationButton.isHidden = true
            changeStyleButton.isHidden = true
            minusZoomButton.isHidden = true
            plusZoomButton.isHidden = true
            trafficButoon.isHidden = true
        }
    }
    
    @objc func location(_ sender: UIButton) {
        let camera = GMSCameraPosition(target: manager.location!.coordinate, zoom: 13)
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
            navigationController?.setNavigationBarHidden(true, animated: true)
            showMenuFunc()
            mapView.selectedMarker = nil
        case true:
            hideMenuFunc()
            navigationController?.setNavigationBarHidden(false, animated: true)
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
    
    @objc func showAllPlaces(_ sender: UIButton) {
        markerArray.removeAll()
        mapView.clear()
        
        switch showAllPlacesOnMap {
        case false:
            for i in placesArray {
                addMarker(i)
            }
        case true:
            for i in placesArray {
                getDistance(place: i, meters: 7000)
            }
        }
        
        showAllPlacesOnMap.toggle()
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
    
    //MARK: - Add marker
    
    func addMarker(_ object: Places) {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: object.latitude, longitude: object.longitude)
        marker.map = mapView
        marker.title = object.name
        marker.userData = object
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
                
                if self.place == nil || self.place.favoriteStatus == false {
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
