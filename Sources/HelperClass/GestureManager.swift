//
//  GestureManager.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import Foundation
import UIKit

class GestureManager {
    static let shared = GestureManager()
    
    private init() {}
    
    // MARK: - Pan Gesture
    func addPanGesture(to view: UIView, target: Any?, action: Selector?) {
        let panGesture = UIPanGestureRecognizer(target: target, action: action)
        view.addGestureRecognizer(panGesture)
    }
    
    // MARK: - Tap Gesture
    func addTapGesture(to view: UIView, target: Any?, action: Selector?, tapCount: Int = 1) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        tapGesture.numberOfTapsRequired = tapCount
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Pinch Gesture
    func addPinchGesture(to view: UIView, target: Any?, action: Selector?) {
        let pinchGesture = UIPinchGestureRecognizer(target: target, action: action)
        view.addGestureRecognizer(pinchGesture)
    }
    
    // MARK: - Rotate Gesture
    func addRotateGesture(to view: UIView, target: Any?, action: Selector?) {
        let rotateGesture = UIRotationGestureRecognizer(target: target, action: action)
        view.addGestureRecognizer(rotateGesture)
    }
    
    // MARK: - Long Press Gesture
    func addLongPressGesture(to view: UIView, target: Any?, action: Selector?) {
        let longPressGesture = UILongPressGestureRecognizer(target: target, action: action)
        view.addGestureRecognizer(longPressGesture)
    }
}
