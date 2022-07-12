//
//  UITextFieldDelegate.swift
//  Diplom-project
//
//  Created by Артем Томило on 6.06.22.
//

import UIKit

extension CreateAccViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard textField.text!.count >= 1 else { return }
        let image = UIImage(named: "noEye")
        eyeButton.setImage(image, for: .normal)
    }
}

extension AccountViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return false }
        
        let newString = (text as NSString).replacingCharacters(in: range, with: string)
        
        textField.text = formatPhoneNumber(number: newString)
        
        return false
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard textField.text!.count >= 1 else { return }
        let image = UIImage(named: "noEye")
        switch textField {
        case newPassField:
            firstEyeButton.setImage(image, for: .normal)
        case repeatNewPassField:
            secondEyeButton.setImage(image, for: .normal)
        default: break
        }
    }
}
