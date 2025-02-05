//
//  UIView_Extension.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import UIKit

//MARK: UIVIEW
extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    @IBInspectable
    var makeCapsule: Bool {
        get{
            if self.layer.cornerRadius == self.bounds.height / 2 {
                return true
            } else {
                return false
            }
        }
        set{
            if newValue {
                layer.cornerRadius = self.bounds.height / 2
                layer.masksToBounds = true
            }
        }
    }
    
    @IBInspectable
    var backgroundImage: UIImage{
        get{
            return self.backgroundImage
        }
        set{
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
            imageView.image = newValue
            imageView.contentMode = .scaleToFill
            self.addSubview(imageView)
            sendSubviewToBack(imageView)
        }
    }
    
    @IBInspectable
    var backgroundColorAlpha: CGFloat {
        get{
            var alpha: CGFloat = 0
            if ((self.backgroundColor?.getRed(nil, green: nil, blue: nil, alpha: &alpha)) != nil) {
                return alpha
            }
            return alpha
        }
        set{
            self.backgroundColor = self.backgroundColor?.withAlphaComponent(newValue)
        }
    }
    
    private struct AssociatedKeys {
        static var stringTag = ObjectIdentifier(String.self)
    }
    
    // Setter for the string tag
    var stringTag: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.stringTag) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.stringTag, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func remove(complete: (() -> Void)? = nil) {
        let newY = UIScreen.main.bounds.height
        UIView.animate(withDuration: 0.33, animations: {
            self.frame.origin.y = newY
        }, completion: { _ in
            self.removeFromSuperview()
            complete?()
        })
    }
}
