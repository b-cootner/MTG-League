//
//  UIViewController+Overlay.swift
//  Whispering-Plateau
//
//  Created by Ben Cootner on 7/12/19.
//  Copyright © 2019 Ben Cootner. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showOverlay(withTitle title: String) -> UIView {
        let overlayView = UIView()
        view.addSubview(overlayView)
        overlayView.backgroundColor = .white
        view.bringSubviewToFront(overlayView)
        overlayView.alpha = 0.75

        var topViewConstraint: NSLayoutConstraint
        if #available(iOS 11.0, *) {
            topViewConstraint = overlayView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        } else {
            topViewConstraint = overlayView.topAnchor.constraint(equalTo: view.topAnchor)
        }

        topViewConstraint.isActive = true
        overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//
//        let label = UILabel()
//        label.text = title
//        label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 15).isActive = true
//        overlayView.addSubview(label)

        return overlayView
    }
}
