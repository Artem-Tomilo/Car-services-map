//
//  PlaceViewController.swift
//  Diplom-project
//
//  Created by Артем Томило on 11.07.22.
//

import UIKit
import CoreLocation
import GooglePlaces

class PlaceViewController: UIViewController {
    
    @IBOutlet var horisontalCollectionView: UICollectionView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var telNumberLabel: UILabel!
    @IBOutlet var webLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var servicesLabel: UILabel!
    
    var urlString = ""
    var urlTelNumber = ""
    
    static let horisontalCellIdentifier = "horisontalCell"
    
    weak var delegate: PlaceViewControllerDelegate?
    
    //MARK: - View did load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .black
        
        horisontalCollectionView.register(HorisontalCustomCellForCollectionView.self, forCellWithReuseIdentifier: PlaceViewController.horisontalCellIdentifier)
        
        collectionViewSettings()
        
        addTapGesture()
    }
    
    //MARK: - View will appear
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    //MARK: - Tap gesture func's
    
    func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(webPressed(_:)))
        webLabel.addGestureRecognizer(tapGesture)
        webLabel.isUserInteractionEnabled = true
        
        let telTapGesture = UITapGestureRecognizer(target: self, action: #selector(telPressed(_:)))
        telNumberLabel.addGestureRecognizer(telTapGesture)
        telNumberLabel.isUserInteractionEnabled = true
    }
    
    @objc func webPressed(_ sender: UITapGestureRecognizer) {
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    @objc func telPressed(_ sender: UITapGestureRecognizer) {
        urlTelNumber = urlTelNumber.components(separatedBy: "-").joined(separator: "")
        urlTelNumber = urlTelNumber.components(separatedBy: .whitespaces).joined(separator: "")
        
        if let url = URL(string: "tel://\(urlTelNumber)") {
            UIApplication.shared.open(url as URL)
        }
    }
    
    //MARK: - Collection view settings
    
    func collectionViewSettings() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(4.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 5)
        let spacing: CGFloat = 5
        group.interItemSpacing = .fixed(spacing)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        let compositionaLayout = UICollectionViewCompositionalLayout(section: section)
        horisontalCollectionView.collectionViewLayout = compositionaLayout
    }
    
    func fetchPlaceData(index: Int, indexPath: IndexPath, cell: HorisontalCustomCellForCollectionView) {
        let client = GMSPlacesClient.shared()
        let fields: GMSPlaceField = [.name, .formattedAddress, .phoneNumber, .rating, .website, .userRatingsTotal, .photos]
        client.fetchPlace(fromPlaceID: (delegate?.favoritePlaces()[index].placeID)!, placeFields: fields, sessionToken: nil) { place, error in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            if let place = place {
                
                let name = NSAttributedString(string: place.name ?? "", attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
                self.nameLabel.attributedText = name
                
                self.addressLabel.text = place.formattedAddress
                
                self.urlTelNumber = place.phoneNumber ?? ""
                self.telNumberLabel.text = "📞 \(place.phoneNumber ?? "-")"
                
                self.ratingLabel.text = "⭐️ \(String(place.rating)) (\(String(place.userRatingsTotal)))"
                
                let url = place.website
                self.urlString = url?.absoluteString ?? ""
                self.webLabel.attributedText = NSAttributedString(string: self.urlString , attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
                
                var arr: [String] = []
                for m in ProfServices.allCases {
                    for i in self.delegate!.favoritePlaces()[index].services {
                        if m == i {
                            arr.append(m.title)
                            let signUpString = NSMutableAttributedString(string: "Services: \(arr.joined(separator: ", ").lowercased())")
                            signUpString.addAttribute(.underlineStyle, value: 1, range: NSRange(location: 0, length: 8))
                            signUpString.addAttribute(.font, value: UIFont.systemFont(ofSize: 22.0, weight: .semibold), range: NSRange(location: 0, length: 8))
                            self.servicesLabel.attributedText = signUpString
                        }
                    }
                }
                
                let photoMetadata: [GMSPlacePhotoMetadata] = [place.photos![0], place.photos![1], place.photos![2], place.photos![3], place.photos![4]]
                client.loadPlacePhoto(photoMetadata[indexPath.item], callback: { (photo, error) -> Void in
                    if let error = error {
                        print("Error loading photo metadata: \(error.localizedDescription)")
                        return
                    } else {
                        cell.firstImage.image = photo
                    }
                })
            }
        }
    }
}

//MARK: - Extension collection view

extension PlaceViewController: UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
}

extension PlaceViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaceViewController.horisontalCellIdentifier, for: indexPath) as? HorisontalCustomCellForCollectionView
        
        cell?.lockView()
        UIView.animate(withDuration: 1) {
            cell?.unlockView()
        }
        
        fetchPlaceData(index: delegate!.index, indexPath: indexPath, cell: cell!)
        return cell!
    }
}

//MARK: - Protocol

protocol PlaceViewControllerDelegate: AnyObject {
    func favoritePlaces() -> [Places]
    var index: Int { get }
}
