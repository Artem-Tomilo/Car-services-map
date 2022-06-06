//
//  CreateAccViewController.swift
//  Diplom-project
//
//  Created by Артем Томило on 1.06.22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase


class CreateAccViewController: UIViewController {

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    
    @IBOutlet var createAccButton: UIButton!
    
    @IBOutlet var nameView: UIView!
    @IBOutlet var emailView: UIView!
    @IBOutlet var passwordView: UIView!
        
    @IBOutlet var eyeButton: UIButton!
    var iconClick = true
    
    let ref = Database.database().reference().child("users")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        createAccButton.layer.cornerRadius = 25
        nameView.layer.cornerRadius = 5
        emailView.layer.cornerRadius = 5
        passwordView.layer.cornerRadius = 5
    }
    
    //MARK: - Create new acc
    
    @IBAction func createAcc(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "") { [weak self]
            authResult, error in
            if let error = error {
                print(error.localizedDescription)
                print(error)
            }
            guard let self = self else { return }
            
            guard let authResult = authResult else {
                switch error {
                case let nsError as NSError where nsError.domain == AuthErrorDomain && nsError.code == AuthErrorCode.emailAlreadyInUse.rawValue:
                    let alert = UIAlertController(title: "Error:", message: "The email address is already in use by another account!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Cancel", style: .cancel)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                case let nsError as NSError where nsError.domain == AuthErrorDomain && nsError.code == AuthErrorCode.weakPassword.rawValue:
                    let alert = UIAlertController(title: "Error:", message: "The password must be 6 characters long or more!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Cancel", style: .cancel)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                case let nsError as NSError where nsError.domain == AuthErrorDomain && nsError.code == AuthErrorCode.invalidEmail.rawValue:
                    let alert = UIAlertController(title: "Error", message: "The email address is badly formatted!", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Cancel", style: .cancel)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                default:
                    print("Unknown error \(String(describing: error))")
                }
                return
            }
            
            self.ref.child(authResult.user.uid).setValue([
                "username": self.usernameTextField.text ?? "",
                "email": self.emailTextField.text ?? ""
            ])
            
            self.navigationController?.setViewControllers([self.storyboard!.instantiateViewController(withIdentifier: "mapViewController")], animated: true)
        }
    }
    
    //MARK: - Done tapped
    
    @IBAction func doneTapped(_ sender: UIControl) {
        sender.resignFirstResponder()
    }
    
    //MARK: - Tap Gesture
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        view.endEditing(false)
    }
    
    //MARK: - Icon Action
    
    @IBAction func iconAction(_ sender: UIButton) {
        if(iconClick == true) {
            passwordTextField.isSecureTextEntry = false
            iconClick = false
            let image = UIImage(named: "eye")
            eyeButton.setImage(image, for: .normal)
        } else {
            passwordTextField.isSecureTextEntry = true
            iconClick = true
            let image = UIImage(named: "noEye")
            eyeButton.setImage(image, for: .normal)
        }
    }
}

extension CreateAccViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard textField.text!.count >= 1 else { return }
        let image = UIImage(named: "noEye")
        eyeButton.setImage(image, for: .normal)
    }
}
