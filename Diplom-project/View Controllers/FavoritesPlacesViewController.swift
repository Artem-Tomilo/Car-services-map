//
//  FavoritesPlacesViewController.swift
//  Diplom-project
//
//  Created by Артем Томило on 6.07.22.
//

import UIKit
import CoreLocation
import GooglePlaces

final class FavoritesPlacesViewController: UIViewController {
    
    //MARK: - IBOutlet
    
    @IBOutlet var verticalCollectionView: UICollectionView!
    
    //MARK: - properties
    
    static let cellIdentifier = "verticalCell"
    
    private var favoritesPlacesArray: [Places] = []
    
    private var placeIndex = 0
    
    //MARK: - View did load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.tintColor = .black
        
        collectionViewSettings()
        
        verticalCollectionView.register(VerticalCustomCellForCollectionView.self, forCellWithReuseIdentifier: FavoritesPlacesViewController.cellIdentifier)
        
        favoritesPlaceFunc()
    }
    
    //MARK: - View will disappear
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    //MARK: - Collection view settings
    
    func collectionViewSettings() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.interGroupSpacing = spacing
        
        let compositionalLayout = UICollectionViewCompositionalLayout(section: section)
        
        verticalCollectionView.collectionViewLayout = compositionalLayout
    }
    
    //MARK: - Favorites places
    
    func favoritesPlaceFunc() {
        let places = DataManager.shared.decodePlace()
        
        for i in places {
            if i.favoriteStatus {
                favoritesPlacesArray.append(i)
            }
        }
    }
}

//MARK: - Extension collection view

extension FavoritesPlacesViewController: UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoritesPlacesArray.count
    }
}

extension FavoritesPlacesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritesPlacesViewController.cellIdentifier, for: indexPath) as? VerticalCustomCellForCollectionView else { return UICollectionViewCell() }
        
        cell.lockView()
        UIView.animate(withDuration: 1) {
            cell.unlockView()
        }
        
        let client = GMSPlacesClient.shared()
        let fields: GMSPlaceField = [.name, .formattedAddress, .phoneNumber, .rating, .website, .photos]
        client.fetchPlace(fromPlaceID: favoritesPlacesArray[indexPath.item].placeID, placeFields: fields, sessionToken: nil) { place, error in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            if let place = place {
                cell.nameText = place.name ?? ""
                cell.adressText = place.formattedAddress ?? ""
                
                let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]
                client.loadPlacePhoto(photoMetadata, callback: { (photo, error) -> Void in
                    if let error = error {
                        print("Error loading photo metadata: \(error.localizedDescription)")
                        return
                    } else {
                        cell.firstImage.image = photo;
                    }
                })
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        placeIndex = indexPath.item
        let vc = storyboard?.instantiateViewController(withIdentifier: "placeViewController") as! PlaceViewController
        navigationController?.pushViewController(vc, animated: true)
        vc.delegate = self
    }
}

//MARK: - Delegate FavoritesPlacesViewController

extension FavoritesPlacesViewController: PlaceViewControllerDelegate {
    var index: Int {
        get {
            placeIndex
        }
    }
    
    func favoritePlaces() -> [Places] {
        return favoritesPlacesArray
    }
    
    
}
