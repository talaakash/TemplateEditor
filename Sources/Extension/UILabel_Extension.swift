//
//  UILabel_Extension.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

import Foundation
import UIKit

extension UILabel {
    func getNeededWidth() -> CGFloat? {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: self.bounds.height)
        if let text = self.text {
            let boundingBox = text.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: self.font ?? UIFont.systemFont(ofSize: 18)], context: nil)
            return ceil(boundingBox.width)
        }
        return nil
    }
}

