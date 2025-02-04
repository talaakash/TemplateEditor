//
//  AlertController.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import Foundation
import UIKit

class WindowManager: UIWindow{
    static let shared = WindowManager()
    private init(){
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene{
            super.init(windowScene: windowScene)
        } else {
            super.init(frame: UIScreen.main.bounds)
        }
        self.backgroundColor = .clear
        self.windowLevel = .normal
    }
    
    func getWindow() -> UIWindow{
        return self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AlertController{
    var alertWindow: UIWindow!
    var alertBox: AlertView!
    var btnCounter = 0
    var tapHandlers: [UIControl: () -> Void] = [:]
    
    init(title: String = "Template Editor", message: String){
        alertWindow = WindowManager.shared.getWindow()
        
        alertBox = UINib(nibName: "AlertView", bundle: packageBundle).instantiate(withOwner: nil).first as? AlertView
        alertBox.alertTitle.text = title
        alertBox.alertMessage.text = message
    }
    
    func setBtn(title: String, isPremiumFeature: Bool = false, handler: @escaping () -> Void){
        let control = UIControl()
        control.backgroundColor = Theme.primaryButtonColor
        control.layer.cornerRadius = (alertBox.btnViewHeight.constant / 2)
        let label = UILabel()
        label.text = title
        let fontSize: CGFloat = isIpad ? 22 : 1 == 0 ? 18 : 20
        label.font = UIFont(name: "RalewayRoman-Bold", size: fontSize)
        label.textAlignment = .center
        label.textColor = Theme.primaryTextColor
        control.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: control.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: control.centerYAnchor)
        ])
        if isUserIsPaid, isPremiumFeature {
            let premiumView = UIImageView(image: UIImage(named: "premiumFeature"))
            premiumView.translatesAutoresizingMaskIntoConstraints = false
            control.addSubview(premiumView)
            NSLayoutConstraint.activate([
                premiumView.widthAnchor.constraint(equalToConstant: 20),
                premiumView.heightAnchor.constraint(equalToConstant: 20),
                premiumView.trailingAnchor.constraint(equalTo: control.trailingAnchor),
                premiumView.topAnchor.constraint(equalTo: control.topAnchor)
            ])
        }
        alertBox.alertBtnView.addArrangedSubview(control)
        control.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        tapHandlers[control] = handler
        
    }
    
    @objc private func buttonTapped(_ sender: UIControl) {
        if let tapHandler = tapHandlers[sender] {
            tapHandler()
            alertBox.removeFromSuperview()
            alertWindow.resignKey()
            alertWindow.isHidden = true
        }
    }
    
    @objc private func closeBtnTapped(_ sender: UIControl) {
        UIView.animate(withDuration: 0.33, animations: {
            self.alertWindow.backgroundColor = .clear
            self.alertBox.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.alertBox.alpha = 0
        }, completion: { _ in
            self.alertBox.removeFromSuperview()
            self.alertWindow.resignKey()
            self.alertWindow.isHidden = true
        })
    }
    
    func showAlertBox(){
        let control = UIControl()
        control.backgroundColor = .clear
        control.translatesAutoresizingMaskIntoConstraints = false
        alertWindow.addSubview(control)
        NSLayoutConstraint.activate([
            control.leadingAnchor.constraint(equalTo: alertWindow.leadingAnchor),
            control.trailingAnchor.constraint(equalTo: alertWindow.trailingAnchor),
            control.topAnchor.constraint(equalTo: alertWindow.topAnchor),
            control.bottomAnchor.constraint(equalTo: alertWindow.bottomAnchor)
        ])
        control.addTarget(self, action: #selector(closeBtnTapped(_:)), for: .touchUpInside)
    
        alertWindow.addSubview(alertBox)
        
        let iPadSpace = alertWindow.frame.width / 4
        let spacing: Double = isIpad ? iPadSpace : 32
        alertBox.translatesAutoresizingMaskIntoConstraints = false
        alertBox.leadingAnchor.constraint(greaterThanOrEqualTo: alertWindow.leadingAnchor, constant: spacing).isActive = true
        alertBox.trailingAnchor.constraint(greaterThanOrEqualTo: alertWindow.trailingAnchor, constant: -spacing).isActive = true
        alertBox.centerYAnchor.constraint(equalTo: alertWindow.centerYAnchor).isActive = true
        alertBox.centerXAnchor.constraint(equalTo: alertWindow.centerXAnchor).isActive = true
        
        alertWindow.makeKeyAndVisible()
        alertBox.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        alertBox.alpha = 0
        UIView.animate(withDuration: 0.33, animations: {
            self.alertBox.alpha = 1
            self.alertBox.transform = .identity
            self.alertWindow.backgroundColor = .black.withAlphaComponent(0.3)
        })
    }
    
}
