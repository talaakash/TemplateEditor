//
//  SecureView.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

import Foundation
import UIKit

class SecureView : UITextField {

    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.isSecureTextEntry = true
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeSecure(to view: UIView){
        guard let secureView = secureContainer else {return}
        view.superview?.addSubview(secureView)
        secureView.addSubview(view)
        secureView.pinEdges()
        view.pinEdges()
    }
    
    weak var secureContainer: UIView? {
        let secureView = self.subviews.filter({ subview in
            type(of: subview).description().contains("CanvasView")
        }).first
        secureView?.translatesAutoresizingMaskIntoConstraints = false
        secureView?.isUserInteractionEnabled = true //To enable child view's userInteraction in iOS 13
        
        return secureView
    }
}

extension UIView {
    func pin(_ type: NSLayoutConstraint.Attribute) {
        translatesAutoresizingMaskIntoConstraints = false
        let constraint = NSLayoutConstraint(item: self, attribute: type, relatedBy: .equal, toItem: superview, attribute: type, multiplier: 1, constant: 0)
        constraint.priority = UILayoutPriority.init(999)
        constraint.isActive = true
    }
    
    func pinEdges() {
        pin(.top)
        pin(.bottom)
        pin(.leading)
        pin(.trailing)
    }
}
