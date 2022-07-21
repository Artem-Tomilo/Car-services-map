//
//  MarkerInfoViewDelegate.swift
//  Diplom-project
//
//  Created by Артем Томило on 21.07.22.
//

import UIKit

extension MapViewController: MarkerInfoViewDelegate {
    
    func favoritesPlaces(_ sender: UIButton) {
        
        guard place != nil else { return }
        placesArray.removeAll { place in
            place.name == self.place!.name
        }
        
        place!.favoriteStatus.toggle()
        
        placesArray.append(place!)
        
        DataManager.shared.encodePlace(type: placesArray)
        
        if place!.favoriteStatus {
            sender.setImage(UIImage(named: "heartRed"), for: .normal)
        } else {
            sender.setImage(UIImage(named: "heartClear"), for: .normal)
        }
    }
}
