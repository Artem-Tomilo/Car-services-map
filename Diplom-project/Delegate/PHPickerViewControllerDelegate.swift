//
//  PHPickerViewControllerDelegate.swift
//  Diplom-project
//
//  Created by Артем Томило on 2.06.22.
//

import UIKit
import FirebaseAuth
import PhotosUI

extension MapViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let firstImage = results.first else { return }
        
        let itemProvider = firstImage.itemProvider
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] photo, error in
                DispatchQueue.main.async {
                    self?.avatarView.image = photo as? UIImage
                }
            }
        }
        dismiss(animated: true)
    }
}
