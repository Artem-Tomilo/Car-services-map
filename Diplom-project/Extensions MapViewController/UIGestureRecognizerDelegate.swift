//
//  UIGestureRecognizerDelegate.swift
//  Diplom-project
//
//  Created by Артем Томило on 1.06.22.
//

import GoogleMaps

extension MapViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
