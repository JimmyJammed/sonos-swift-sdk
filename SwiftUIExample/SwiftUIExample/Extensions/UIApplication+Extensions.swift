//
//  UIApplication+Extensions.swift
//  SwiftUIExample
//
//  Created by James Hickman on 9/22/21.
//

import UIKit

extension UIApplication {

    func addTapGestureRecognizer() {
        guard let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first else { return }
        let tapGesture = UITapGestureRecognizer(target: keyWindow, action: #selector(UIView.endEditing))
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        tapGesture.name = "UIApplicationDismissTapGesture"
        keyWindow.addGestureRecognizer(tapGesture)
    }

 }

extension UIApplication: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false // set to `false` if you don't want to detect tap during other gestures
    }

}
