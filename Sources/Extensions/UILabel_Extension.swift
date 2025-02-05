//
//  UILabel_Extension.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

import Foundation
import UIKit

extension String{
    func localize() -> String {
        let language = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "en"
        let path = Bundle.main.path(forResource: language, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, bundle: bundle!, comment: "")
    }
}

extension UILabel {
    @IBInspectable
    var localiseKey: String? {
        get {
            return ""
        }
        set {
            let newText = newValue?.localize()
            self.text = newText == newValue ? self.text : newText
        }
    }
    
    func getNeededWidth() -> CGFloat? {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: self.bounds.height)
        if let text = self.text {
            let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font ?? UIFont.systemFont(ofSize: 18)], context: nil)
            return ceil(boundingBox.width)
        }
        return nil
    }
}

