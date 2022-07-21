//
//  LoginViewController.swift
//  Diplom-project
//
//  Created by Артем Томило on 1.06.22.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import FirebaseDatabase

final class LoginViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var emailView: UIView!
    @IBOutlet var passwordView: UIView!
    
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var googleButton: GIDSignInButton!
    @IBOutlet var forgetPasswordButton: UIButton!
    
    @IBOutlet var eyeButton: UIButton!
    
    //MARK: - private properties
    
    private var iconClick = true
    
    //MARK: - View did load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.layer.cornerRadius = 25
        googleButton.style = .wide
        emailView.layer.cornerRadius = 5
        passwordView.layer.cornerRadius = 5
    }
    
    //MARK: - Sign in with Google
    
    @IBAction func signInWithGoogle(_ sender: GIDSignInButton) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let authentication = user?.authentication,
                  let idToken = authentication.idToken
            else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                guard let user = authResult?.user else { return }
                print(user.displayName ?? "Success")
                
                let ref = Database.database().reference().child("users")
                ref.child(user.uid).setValue([
                    "username": user.displayName,
                    "email": user.email
                ])
                
                self.navigationController?.setViewControllers([self.storyboard!.instantiateViewController(withIdentifier: "mapViewController")], animated: true)
            }
        }
    }
    
    //MARK: - Log in
    
    @IBAction func logInAccount(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: emailTextField.text ?? "", password: passwordTextField.text ?? "") { [weak self]
            authResult, error in
            guard let self = self else { return }
            guard authResult != nil else {
                switch error {
                    
                case let nsError as NSError where nsError.domain == AuthErrorDomain && nsError.code == AuthErrorCode.wrongPassword.rawValue:
                    let alert = UIAlertController(title: "Error:", message: "Wrong email or password", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Cancel", style: .cancel)
                    alert.addAction(action)
                    self.present(alert, animated: true)
                    
                case let nsError as NSError where nsError.domain == AuthErrorDomain && nsError.code == AuthErrorCode.userNotFound.rawValue:
                    let alert = UIAlertController(title: "Error:", message: "User with this e-mail address is not registered", preferredStyle: .alert)
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
            
            self.navigationController?.setViewControllers([self.storyboard!.instantiateViewController(withIdentifier: "mapViewController")], animated: true)
        }
    }
    
    //MARK: - Forget password
    
    @IBAction func forgetPassword() {
        let newVC = (storyboard?.instantiateViewController(withIdentifier: "passwordRecoveryViewController")) as! PasswordRecoveryViewController
        present(newVC, animated: true)
    }
    
    //MARK: - Create new account
    
    @IBAction func createAccount(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "createAccViewController") as! CreateAccViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - Done button
    
    @IBAction func doneTapped(_ sender: UIControl) {
        sender.resignFirstResponder()
    }
    
    //MARK: - Tap gesture
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        view.endEditing(false)
    }
    
    //MARK: - Icon action
    
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

//MARK: - extension UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard textField.text!.count >= 1 else { return }
        let image = UIImage(named: "noEye")
        eyeButton.setImage(image, for: .normal)
    }
}

