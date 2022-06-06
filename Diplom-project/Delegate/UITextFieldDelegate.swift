//
//  UITextFieldDelegate.swift
//  Diplom-project
//
//  Created by Артем Томило on 6.06.22.
//

import UIKit

extension AccountViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else { return false }

                let newString = (text as NSString).replacingCharacters(in: range, with: string)

                textField.text = formatPhoneNumber(number: newString)

                return false
    }
}
