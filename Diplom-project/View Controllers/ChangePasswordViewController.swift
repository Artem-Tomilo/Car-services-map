//
//  ChangePasswordViewController.swift
//  Diplom-project
//
//  Created by Артем Томило on 7.06.22.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import FirebaseDatabase

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet var newPassField: UITextField!
    @IBOutlet var firstEyeButton: UIButton!
    @IBOutlet var repeatNewPassField: UITextField!
    @IBOutlet var secondEyeButton: UIButton!
    @IBOutlet var confirmPassButton: UIButton!
    
    var firstIconClick = true
    var secondIconClick = true
    var thirdIconClick = true

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.tintColor = .black
        confirmPassButton.layer.cornerRadius = 25
        newPassField.layer.cornerRadius = 5
        repeatNewPassField.layer.cornerRadius = 10
    }
    
    //MARK: - Update Password
    
    @IBAction func updatePassword(_ sender: UIButton) {
        
        guard newPassField.text == repeatNewPassField.text else {
            let alert = UIAlertController(title: "Error:", message: "The entered passwords do not match", preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }
        guard repeatNewPassField.text!.count >= 6 else {
            let alert = UIAlertController(title: "Error:", message: "The password must be 6 characters long or more!", preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }
        Auth.auth().currentUser?.updatePassword(to: repeatNewPassField.text ?? "") { error in
            guard error == nil else {
                switch error {
                case let nsError as NSError where nsError.domain == AuthErrorDomain && nsError.code == AuthErrorCode.requiresRecentLogin.rawValue:
                    let alert = UIAlertController(title: "Error:", message: "This operation is sensitive and requires recent authentication. Log in again before retrying this request.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Retry login", style: .default) { _ in
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                    let secondAction = UIAlertAction(title: "Cancel", style: .cancel)
                    alert.addAction(action)
                    alert.addAction(secondAction)
                    self.present(alert, animated: true)
                default:
                    break
                }
                return
            }
            let alert = UIAlertController(title: "Your password has been successfully changed", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            alert.addAction(action)
            self.present(alert, animated: true)
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
        switch sender {
        case firstEyeButton:
            if secondIconClick == true {
                newPassField.isSecureTextEntry = false
                secondIconClick = false
                let image = UIImage(named: "eye")
                sender.setImage(image, for: .normal)
            } else if secondIconClick == false {
                newPassField.isSecureTextEntry = true
                secondIconClick = true
                let image = UIImage(named: "noEye")
                sender.setImage(image, for: .normal)
            }
        case secondEyeButton:
            if thirdIconClick == true {
                repeatNewPassField.isSecureTextEntry = false
                thirdIconClick = false
                let image = UIImage(named: "eye")
                sender.setImage(image, for: .normal)
            } else if thirdIconClick == false {
                repeatNewPassField.isSecureTextEntry = true
                thirdIconClick = true
                let image = UIImage(named: "noEye")
                sender.setImage(image, for: .normal)
            }
        default:
            break
        }
    }
}
