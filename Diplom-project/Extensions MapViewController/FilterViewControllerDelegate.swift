//
//  FilterViewControllerDelegate.swift
//  Diplom-project
//
//  Created by Артем Томило on 21.07.22.
//

import UIKit

extension MapViewController: FilterViewControllerDelegate {
    
    func filterMap(with set: Set<ProfServices>) {
        filterFunc(service: set)
    }
}
