//
//  FontManager.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import Foundation
import UIKit

class FontManager {
    static var fontStyles = ["Helvetica", "Arial", "Times New Roman", "Courier New", "Verdana", "Montez", "Montserrat", "Playfair Display", "EB Garamond", "Dosis", "Akronim", "Raleway"]
    static var customFonts = [String]()
    
    static func registerFont(with fontData: Data) -> String? {
        guard let provider = CGDataProvider(data: fontData as CFData),
              let font = CGFont(provider) else {
            return nil
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            if let error = error {
                debugPrint("Failed to register font: \(error.takeUnretainedValue())")
            }
            return nil
        }
        return font.fullName as String?
    }
}

