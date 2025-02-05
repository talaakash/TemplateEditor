//
//  ProgressView.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

import Foundation
import UIKit

public class ProgressView: UIWindow {
    public static let shared = ProgressView()
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    private let circleLayer = CAShapeLayer()
    private let animationDuration: TimeInterval = 2
    
    private init() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            super.init(windowScene: windowScene)
        } else {
            super.init(frame: UIScreen.main.bounds)
        }
        self.backgroundColor = .clear
        self.windowLevel = .normal
        self.isUserInteractionEnabled = true
        addComponentsInWindow()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init coder has not been implemented")
    }
}

// MARK: Private methods
extension ProgressView {
    private func addComponentsInWindow(){
        self.addSubview(containerView)
        
        let containerViewSize: CGFloat = 100
        let containerViewOriginY: CGFloat = (self.bounds.height - containerViewSize) / 2
        
        containerView.frame = CGRect(
            x: (self.bounds.width - containerViewSize) / 2,
            y: containerViewOriginY,
            width: containerViewSize,
            height: containerViewSize
        )
        
        circleLayer.frame = containerView.bounds
        let center = CGPoint(x: containerView.bounds.midX, y: containerView.bounds.midY)
        let radius: CGFloat = containerView.bounds.width / 4
        let startAngle: CGFloat = 0
        let endAngle: CGFloat = .pi * 1.5 // 75% of the circle
        let circlePath = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        circleLayer.path = circlePath.cgPath
        circleLayer.strokeColor = UIColor.black.cgColor
        circleLayer.lineWidth = 2
        circleLayer.fillColor = UIColor.clear.cgColor
        containerView.layer.addSublayer(circleLayer)
    }
    
    private func addAnimations(){
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = 2 * 3.14
        rotationAnimation.duration = animationDuration
        rotationAnimation.repeatCount = .infinity
        rotationAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        circleLayer.add(rotationAnimation, forKey: "rotationAnimation")
        
        let strokeEndAnimation = CABasicAnimation(keyPath: "strokeEnd")
        strokeEndAnimation.fromValue = 0
        strokeEndAnimation.toValue = 1
        strokeEndAnimation.duration = animationDuration
        strokeEndAnimation.repeatCount = .infinity
        strokeEndAnimation.autoreverses = true
        strokeEndAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        circleLayer.add(strokeEndAnimation, forKey: "strokeEndAnimation")
    }
    
    private func removeAnimations(){
        circleLayer.removeAllAnimations()
    }
}

// MARK: Public methods
extension ProgressView {
    public func showProgress() {
        self.makeKeyAndVisible()
        self.addAnimations()
    }
    
    public func hideProgress() {
        self.removeAnimations()
        self.resignKey()
        self.isHidden = true
    }
}
