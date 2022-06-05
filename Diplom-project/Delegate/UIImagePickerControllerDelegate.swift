//
//  UIImagePickerControllerDelegate.swift
//  Diplom-project
//
//  Created by Артем Томило on 2.06.22.
//

import UIKit
import FirebaseAuth
import FirebaseStorage

extension AccountViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else { return }
        
        let myImageReference = avatarsRef.child(Auth.auth().currentUser!.uid + ".jpg")
        
        let data = image.jpegData(compressionQuality: 0.7)!
        
        let _ = myImageReference.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else { return }
            let size = metadata.size
            print(size)
        }
        picker.dismiss(animated: true)
        
        guard let imageURL = info[.imageURL] as? URL,
              let imageData = try? Data(contentsOf: imageURL) else { return }
        avatarView.image = UIImage(data: imageData)
        avatarView.layer.cornerRadius = 50
        avatarView.clipsToBounds = true
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
