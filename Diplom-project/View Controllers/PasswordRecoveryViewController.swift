//
//  PasswordRecoveryViewController.swift
//  Diplom-project
//
//  Created by Артем Томило on 1.06.22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class PasswordRecoveryViewController: UIViewController {

    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var sendEmailButton: UIButton!
    @IBOutlet var emailView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        sendEmailButton.layer.cornerRadius = 25
        emailView.layer.cornerRadius = 5
    }
    
    @IBAction func sendEmail(_ sender: UIButton) {
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text ?? "") { error in
            guard let error = error else {
                let alert = UIAlertController(title: "Password recovery", message: "A password reset email has been sent to you", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .cancel) { _ in
                    self.dismiss(animated: true)
                }
                alert.addAction(action)
                self.present(alert, animated: true)
                return
            }
            switch error {
            case let nsError as NSError where nsError.domain == AuthErrorDomain && nsError.code == AuthErrorCode.userNotFound.rawValue:
                let alert = UIAlertController(title: "Error", message: "Users with this email are not registered", preferredStyle: .alert)
                let action = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(action)
                self.present(alert, animated: true)
            case let nsError as NSError where nsError.domain == AuthErrorDomain && nsError.code == AuthErrorCode.invalidEmail.rawValue:
                let alert = UIAlertController(title: "Error", message: "The email address is badly formatted!", preferredStyle: .alert)
                let action = UIAlertAction(title: "Cancel", style: .cancel)
                alert.addAction(action)
                self.present(alert, animated: true)
            default:
                print(error.localizedDescription)
                print(error)
            }
        }
    }
    
    @IBAction func doneTapped(_ sender: UIControl) {
        sender.resignFirstResponder()
    }
}
