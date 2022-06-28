//
//  UIView + extensions.swift
//  Diplom-project
//
//  Created by Артем Томило on 20.06.22.
//

import UIKit

extension UIView {
    
    class func viewFromNibName(_ name: String) -> UIView? {
        let views = Bundle.main.loadNibNamed(name, owner: nil, options: nil)
        return views?.first as? UIView
    }
    
    func lockView() {
        if let _ = viewWithTag(10) {
        } else {
            let lockView = UIView(frame: bounds)
            lockView.backgroundColor = UIColor(white: 1, alpha: 1)
            lockView.tag = 10
            lockView.alpha = 0.0
            let activity = UIActivityIndicatorView(style: .medium)
            activity.color = .black
            activity.hidesWhenStopped = true
            activity.center = lockView.center
            lockView.addSubview(activity)
            activity.startAnimating()
            addSubview(lockView)
            
            UIView.animate(withDuration: 0.2) {
                lockView.alpha = 1.0
            }
        }
    }
    
    func unlockView() {
        if let lockView = viewWithTag(10) {
            UIView.animate(withDuration: 0.2) {
                lockView.alpha = 0.0
            } completion: { _ in
                lockView.removeFromSuperview()
            }
        }
    }
}

