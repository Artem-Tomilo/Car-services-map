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
    @IBOutlet var telNumberLabel: UILabel!
    @IBOutlet var deleteAvatarButton: UIButton!
    
    let ref = Database.database().reference().child("users")
    let storage = Storage.storage()
    lazy var avatarsRef = storage.reference().child("avatars/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        selectAvatar()

        avatarView.layer.cornerRadius = 50
        deleteAvatarButton.layer.cornerRadius = 20
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeTelNumber(_:)))
        telNumberLabel.addGestureRecognizer(tapGesture)
        telNumberLabel.isUserInteractionEnabled = true
        tapGesture.delegate = self
    }
    
    //MARK: - Change tel number function
    
    @objc func changeTelNumber(_ sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Do you want to edit your number?", message: "", preferredStyle: .actionSheet)
        let firstAction = UIAlertAction(title: "Yes", style: .default) { action in
            let alert = UIAlertController(title: "Enter your number", message: "", preferredStyle: .alert)
            alert.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Your number"
                textField.delegate = self
            }
            
            let action = UIAlertAction(title: "Add number", style: .default) { action in
                if let textField = alert.textFields?[0] {
                    let userID = Auth.auth().currentUser?.uid
                    let userRef = self.ref.child(userID!)
                    userRef.updateChildValues(["telNumber" : textField.text ?? ""])
                    self.telNumberLabel.text = """
                    Your number:
                    \(textField.text ?? "-  -")
                    """
                }
            }
            let secondAction = UIAlertAction(title: "Cancel", style: .default) { _ in
                self.dismiss(animated: true)
            }
            
            alert.addAction(action)
            alert.addAction(secondAction)
            self.present(alert, animated: true)
        }
        let secondAction = UIAlertAction(title: "No", style: .destructive) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        present(alert, animated: true)
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
            let _ = allUsers.compactMap { k, v -> Person? in
                guard let values = v as? Dictionary<String, String>,
                      let username = values["username"],
                      let email = values["email"] else { return nil }
                if Auth.auth().currentUser?.uid == k {
                    
                    self.nameLabel.text = """
                    Your username:
                    \(username)
                    """
                    
                    self.emailLabel.text = """
                    Your email:
                    \(email)
                    """
                    
                    let telNumber = values["telNumber"]
                    self.telNumberLabel.text = """
                    Your number:
                    \(telNumber ?? "-  -")
                    """
                    
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
    
    //MARK: - Delete avatar image
    
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
    
    //MARK: - Back to MapVC button
    
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
    
    //MARK: - Format phone number
    
    func formatPhoneNumber(number: String) -> String {
        
        let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        
        let mask = "+XXX (XX) XXX-XX-XX"
        
        var result = ""
        
        var index = cleanPhoneNumber.startIndex
        
        for ch in mask where index < cleanPhoneNumber.endIndex {
            
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}
