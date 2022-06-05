//
//  AccountViewController.swift
//  Diplom-project
//
//  Created by Артем Томило on 5.06.22.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase
import FirebaseStorage

class AccountViewController: UIViewController {
    
    @IBOutlet var avatarView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var deleteAvatarButton: UIButton!
    
    let ref = Database.database().reference().child("users")
    let storage = Storage.storage()
    lazy var avatarsRef = storage.reference().child("avatars/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        selectAvatar()
        avatarView.layer.cornerRadius = 50
    }
    
    func getData() {
        ref.getData(completion:  { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let allUsers = snapshot?.value as? Dictionary<String, Any> else {
                return
            }
            let _ = allUsers.compactMap { k, v -> Person? in
                guard let values = v as? Dictionary<String, String>,
                      let username = values["username"],
                      let email = values["email"] else { return nil }
                if Auth.auth().currentUser?.uid == k {
                    self.nameLabel.text = "\(username)"
                    self.emailLabel.text = "\(email)"
                    let myImageReference = self.avatarsRef.child(Auth.auth().currentUser!.uid + ".jpg")
                    myImageReference.getData(maxSize: 5 * 1024 * 1024) { data, error in
                        if let error = error {
                            print(error.localizedDescription)
                            self.avatarView.layer.cornerRadius = 0
                        } else {
                            let image = UIImage(data: data!)
                            
                            DispatchQueue.main.async {
                                self.avatarView.image = image
                            }
                        }
                    }
                }
                return Person(uid: k, username: username, email: email)
            }
        })
    }
    
    @IBAction func deleteAvatar() {
        let myImageReference = self.avatarsRef.child(Auth.auth().currentUser!.uid + ".jpg")
        myImageReference.delete { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.avatarView.image = UIImage(named: "photo")
                self.avatarView.layer.cornerRadius = 0
            }
        }
        
    }
    
    @IBAction func backToMapVC(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
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
    
}
