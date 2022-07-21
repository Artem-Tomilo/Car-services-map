//
//  UIGestureRecognizerDelegate + extension AccountViewController.swift
//  Diplom-project
//
//  Created by Артем Томило on 21.07.22.
//

import GoogleMaps

extension AccountViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
