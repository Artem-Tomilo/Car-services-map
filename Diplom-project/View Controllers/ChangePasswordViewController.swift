//
//  ChangePasswordViewController.swift
//  Diplom-project
//
//  Created by Артем Томило on 7.06.22.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet var oldPassField: UITextField!
    @IBOutlet var firstEyeButton: UIButton!
    @IBOutlet var newPassField: UITextField!
    @IBOutlet var secondEyeButton: UIButton!
    @IBOutlet var repeatNewPassField: UITextField!
    @IBOutlet var thirdEyeButton: UIButton!
    @IBOutlet var confirmPassButton: UIButton!
    
    var iconClick = true

    override func viewDidLoad() {
        super.viewDidLoad()
        confirmPassButton.layer.cornerRadius = 25
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
            if iconClick == true {
                oldPassField.isSecureTextEntry = false
                iconClick = false
                let image = UIImage(named: "eye")
                sender.setImage(image, for: .normal)
            } else if iconClick == false {
                oldPassField.isSecureTextEntry = true
                iconClick = true
                let image = UIImage(named: "noEye")
                sender.setImage(image, for: .normal)
            }
        case secondEyeButton:
            if iconClick == true {
                newPassField.isSecureTextEntry = false
                iconClick = false
                let image = UIImage(named: "eye")
                sender.setImage(image, for: .normal)
            } else if iconClick == false {
                newPassField.isSecureTextEntry = true
                iconClick = true
                let image = UIImage(named: "noEye")
                sender.setImage(image, for: .normal)
            }
        case thirdEyeButton:
            if iconClick == true {
                repeatNewPassField.isSecureTextEntry = false
                iconClick = false
                let image = UIImage(named: "eye")
                sender.setImage(image, for: .normal)
            } else if iconClick == false {
                repeatNewPassField.isSecureTextEntry = true
                iconClick = true
                let image = UIImage(named: "noEye")
                sender.setImage(image, for: .normal)
            }
        default:
            break
        }
    }
}
