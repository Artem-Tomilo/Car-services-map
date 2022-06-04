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
import CoreLocation
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseStorage

class MapViewController: UIViewController {
    
    var mapView: GMSMapView!
    let someView = UIView()
    let viewForUserData = UIView()
    let avatarView = UIImageView()
    let clearView = UIView()
    let tableView = UITableView()
    let nameLabel = UILabel()
    
    var showMenuConstraint: NSLayoutConstraint!
    var hiddenMenuConstraint: NSLayoutConstraint!
    var showClearViewConstraint: NSLayoutConstraint!
    var hiddenClearViewConstraint: NSLayoutConstraint!
    
    let changeStyleButton = UIButton()
    let minusZoomButton = UIButton()
    let plusZoomButton = UIButton()
    let hiddenButton = UIButton()
    let showMenuButton = UIButton()
    let signOutButton = UIButton()
    
    static let path = try! FileManager.default.url(for: .cachesDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
    static let jsonPath = path.appendingPathComponent("marker.json")
    
    var lightStyle = false
    var showTableView = false

    let ref = Database.database().reference().child("users")
    let storage = Storage.storage()
    lazy var avatarsRef = storage.reference().child("avatars/")
    
    var jsonMarker: [MyAnnotations] = []
    var users: [Person] = []
    
    var text: String!

    let manager = CLLocationManager()
    
    var cluster: GMUClusterManager!
    
    let listTableViewMenu = ["Advanced filter", "My addresses", "Account", "About app"]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapSettings()
        
        clusterFunc()
        
        createButtons()
                
        locationSettings()
        
        decode()
        
        tableViewSettings()
        
        selectAvatar()
        
        getData()
    }
    
    //MARK: - Get data function
    
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
                    
                    let myImageReference = self.avatarsRef.child(Auth.auth().currentUser!.uid + ".jpg")
                    myImageReference.getData(maxSize: 5 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error.localizedDescription)
                        } else {
                            let image = UIImage(data: data!)
                            
                            DispatchQueue.main.async {
                                self.avatarView.image = image
                            }
                        }
                    }
                }
                let user = Person(uid: k, username: username, email: email)
                self.users.append(user)
                return Person(uid: k, username: username, email: email)
            }
            self.users = users
            print(users)
        })
    }
    
    //MARK: - Image picker
    
    func selectAvatar() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped(_:)))
        avatarView.addGestureRecognizer(tapGesture)
        avatarView.isUserInteractionEnabled = true
        tapGesture.delegate = self
    }
    
    @objc func avatarTapped(_ sender: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
        picker.allowsEditing = true
    }
    
    //MARK: - Table view settings
    
    func tableViewSettings() {
        
        //MARK: - someview
        
        view.addSubview(someView)
        someView.translatesAutoresizingMaskIntoConstraints = false
        showMenuConstraint = someView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        hiddenMenuConstraint = someView.trailingAnchor.constraint(equalTo: view.leadingAnchor)
        NSLayoutConstraint.activate([
            someView.topAnchor.constraint(equalTo: view.topAnchor),
            someView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            someView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            hiddenMenuConstraint])
        someView.backgroundColor = .systemGray4
        someView.alpha = 1
        
        //MARK: - viewForUserData
        
        someView.addSubview(viewForUserData)
        viewForUserData.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            viewForUserData.topAnchor.constraint(equalTo: someView.safeAreaLayoutGuide.topAnchor, constant: 20),
            viewForUserData.trailingAnchor.constraint(equalTo: someView.trailingAnchor),
            viewForUserData.leadingAnchor.constraint(equalTo: someView.leadingAnchor),
            viewForUserData.heightAnchor.constraint(equalToConstant: 50)
        ])
        viewForUserData.backgroundColor = .systemMint
        
        //MARK: - nameLabel
        
        viewForUserData.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: viewForUserData.topAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: viewForUserData.trailingAnchor),
            nameLabel.bottomAnchor.constraint(equalTo: viewForUserData.bottomAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: viewForUserData.leadingAnchor, constant: 120)
        ])
        nameLabel.numberOfLines = 0
        nameLabel.font = UIFont.italicSystemFont(ofSize: 20)
        
        //MARK: - showMenuButton
        
        view.addSubview(showMenuButton)
        showMenuButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            showMenuButton.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            showMenuButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            showMenuButton.widthAnchor.constraint(equalToConstant: 30),
            showMenuButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        showMenuButton.setImage(UIImage(named: "menu"), for: .normal)
        showMenuButton.backgroundColor = .white
        showMenuButton.alpha = 0.5
        showMenuButton.layer.cornerRadius = 15
        showMenuButton.addTarget(self, action: #selector(showTableView(_:)), for: .primaryActionTriggered)
        
        //MARK: - avatarView
        
        viewForUserData.addSubview(avatarView)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            avatarView.trailingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -25),
            avatarView.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 40),
            avatarView.heightAnchor.constraint(equalToConstant: 40)
            ])
        avatarView.frame.size = CGSize(width: 40, height: 40)
        avatarView.layer.cornerRadius = 20
        avatarView.clipsToBounds = true
        avatarView.image = UIImage(named: "photo")
        
        //MARK: - signOutButton
        
        someView.addSubview(signOutButton)
        signOutButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            signOutButton.bottomAnchor.constraint(equalTo: someView.safeAreaLayoutGuide.bottomAnchor),
            signOutButton.leadingAnchor.constraint(equalTo: someView.leadingAnchor, constant: 40),
            signOutButton.trailingAnchor.constraint(equalTo: someView.trailingAnchor, constant: -40),
            signOutButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        signOutButton.backgroundColor = .black
        signOutButton.layer.cornerRadius = 20
        signOutButton.setTitle("Sign Out", for: .normal)
        signOutButton.tintColor = .white
        signOutButton.addTarget(self, action: #selector(signOut(_:)), for: .primaryActionTriggered)
        
        //MARK: - tableView
        
        someView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: viewForUserData.bottomAnchor, constant: 30),
            tableView.leadingAnchor.constraint(equalTo: someView.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: someView.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: signOutButton.topAnchor)
        ])
        tableView.backgroundColor = .systemGray4
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "table-cell")
        
        //MARK: - Clear view
        
        view.addSubview(clearView)
        clearView.translatesAutoresizingMaskIntoConstraints = false
        showClearViewConstraint = clearView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        hiddenClearViewConstraint = clearView.leadingAnchor.constraint(equalTo: view.trailingAnchor)
        
        NSLayoutConstraint.activate([
            clearView.topAnchor.constraint(equalTo: view.topAnchor),
            clearView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            clearView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            hiddenClearViewConstraint
        ])
        clearView.backgroundColor = .systemGray6
        clearView.alpha = 0.5
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tap(_:)))
        clearView.addGestureRecognizer(tapGesture)
        clearView.isUserInteractionEnabled = true
        tapGesture.delegate = self
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        NSLayoutConstraint.deactivate([showMenuConstraint, showClearViewConstraint])
        NSLayoutConstraint.activate([hiddenMenuConstraint, hiddenClearViewConstraint])
        view.setNeedsLayout()
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
        
        showMenuButton.backgroundColor = .white
        showMenuButton.alpha = 0.5
        showTableView = false
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
    
    func buttonSettings(button: UIButton, viewV: UIView, nameImage: String, constant: CGFloat) {
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 56),
            button.heightAnchor.constraint(equalToConstant: 56),
            button.bottomAnchor.constraint(equalTo: viewV.bottomAnchor, constant: constant),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        button.setImage(UIImage(named: nameImage), for: .normal)
        button.layer.cornerRadius = 28
    }
    
    func createButtons() {
        
        buttonSettings(button: changeStyleButton, viewV: view, nameImage: "sun", constant: -112)
        buttonSettings(button: minusZoomButton, viewV: changeStyleButton, nameImage: "minus", constant: -69)
        buttonSettings(button: plusZoomButton, viewV: minusZoomButton, nameImage: "plus", constant: -69)
//        buttonSettings(button: hiddenButton, viewV: view, nameImage: "", constant: -42)
        
//        styleButton.isHidden = true
//        minusZoomButton.isHidden = true
//        plusZoomButton.isHidden = true
        
        changeStyleButton.addTarget(self, action: #selector(styleButtonTapped(_:)), for: .primaryActionTriggered)
        minusZoomButton.addTarget(self, action: #selector(minusOneZoom(_:)), for: .primaryActionTriggered)
        plusZoomButton.addTarget(self, action: #selector(plusOneZoom(_:)), for: .primaryActionTriggered)
        hiddenButton.addTarget(self, action: #selector(hiddenButtons(_:)), for: .primaryActionTriggered)
    }
    
    
    
    //MARK: - Button actions
    
    @objc func styleButtonTapped(_ sender: UIButton) {
        if lightStyle {
            style(for: "darkStyle", withExtension: ".json")
            changeStyleButton.setImage(UIImage(named: "sun"), for: .normal)
            lightStyle = false
            if lightStyle == false && hiddenMenuConstraint.isActive == true {
                showMenuButton.backgroundColor = .white
            }
        } else {
            style(for: "lightStyle", withExtension: ".json")
            changeStyleButton.setImage(UIImage(named: "dark"), for: .normal)
            lightStyle = true
            showMenuButton.backgroundColor = .clear
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
    
    @objc func hiddenButtons(_ sender: UIButton) {
        if changeStyleButton.isHidden == false {
            changeStyleButton.isHidden = true
            plusZoomButton.isHidden = true
            minusZoomButton.isHidden = true
            hiddenButton.isHidden = false
        } else {
            changeStyleButton.isHidden = false
            plusZoomButton.isHidden = false
            minusZoomButton.isHidden = false
            hiddenButton.isHidden = true
        }
    }
    
    @objc func showTableView(_ sender: UIButton) {
        switch showTableView {
        case false:
            NSLayoutConstraint.deactivate([hiddenMenuConstraint, hiddenClearViewConstraint])
            NSLayoutConstraint.activate([showMenuConstraint, showClearViewConstraint])
            view.setNeedsLayout()
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            showMenuButton.backgroundColor = .clear
            showMenuButton.alpha = 1
            
            showTableView = true
        case true:
            NSLayoutConstraint.deactivate([showMenuConstraint, showClearViewConstraint])
            NSLayoutConstraint.activate([hiddenMenuConstraint, hiddenClearViewConstraint])
            view.setNeedsLayout()
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
            showMenuButton.backgroundColor = .white
            showMenuButton.alpha = 0.5
            
            showTableView = false
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
        let camera = GMSCameraPosition.camera(withLatitude: 53.90, longitude: 27.56, zoom: 5)
//        let camera = GMSCameraPosition(target: CLLocationCoordinate2D(latitude: manager.location?.coordinate.latitude ?? 0, longitude: manager.location?.coordinate.longitude ?? 0), zoom: 10)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
//        mapView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
//        mapView.isTrafficEnabled = true
        mapView.isMyLocationEnabled = true
        style(for: "darkStyle", withExtension: ".json")
        view = mapView
        navigationController?.setNavigationBarHidden(true, animated: false)

        mapView.delegate = self

        let zoom = GMSCameraUpdate.zoom(to: 10.7)
        mapView.animate(with: zoom)
    }

    //MARK: - Decode

    func decode() {
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: MapViewController.jsonPath) else { return }
        guard let results = try? decoder.decode([MyAnnotations].self, from: data) else { return }
        jsonMarker += results

        for i in jsonMarker {
            let coor = CLLocationCoordinate2D(latitude: i.latitude, longitude: i.longitude)
            addMarker(in: coor, name: i.name)
        }
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

    //MARK: - Home annotation

    func homeAnnotation() {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 53.85464, longitude: 27.48490)
        marker.title = "Artem"
        marker.snippet = "House"
        marker.map = mapView
        marker.isFlat = true
        marker.icon = GMSMarker.markerImage(with: .blue)
    }

    //MARK: - Add marker

    func addMarker(in position: CLLocationCoordinate2D, name: String) {
        let marker = GMSMarker()
        marker.position = position
        marker.map = mapView
        marker.title = name
        cluster.add(marker)
        cluster.cluster()
    }
}
