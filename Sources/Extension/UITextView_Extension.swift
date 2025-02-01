//
//  UITextView_Extension.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import UIKit

extension UITextView {
    private struct AssociatedKeys {
        static var placeHolder = ObjectIdentifier(String.self)
    }
    
    @IBInspectable
    var placeHolder: String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.placeHolder) as? String
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.placeHolder, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            self.text = newValue
            self.textColor = .lightGray
            NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidBeginEditing), name: UITextView.textDidBeginEditingNotification, object: self)
            NotificationCenter.default.addObserver(self, selector: #selector(handleTextDidEndEditing), name: UITextView.textDidEndEditingNotification, object: self)
        }
    }
    
    @objc private func handleTextDidBeginEditing() {
        if self.text == placeHolder {
            self.text = ""
            self.textColor = .black
        }
    }
    
    @objc private func handleTextDidEndEditing() {
        if self.text.isEmpty {
            self.text = placeHolder
            self.textColor = .lightGray
        } else {
            self.textColor = .black
        }
    }
    
    func centerTextVertically() {
        let size = self.sizeThatFits(CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude))
        let topOffset = (self.bounds.size.height - size.height * self.zoomScale) / 2
        let positiveTopOffset = max(1, topOffset)
        self.contentOffset.y = -positiveTopOffset
        self.layoutIfNeeded()
    }
}
