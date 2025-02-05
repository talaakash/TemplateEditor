//
//  UIImage_Extension.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import UIKit
import CoreImage

extension UIImage {
    
    func resizeImage(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func flippedHorizontally() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: self.size.width, y: 0)
        context?.scaleBy(x: -1.0, y: 1.0)
        self.draw(at: CGPoint.zero)
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return flippedImage
    }
    
    func flippedVertically() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        self.draw(at: CGPoint.zero)
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return flippedImage
    }
    
    func applyBlur(with radius: CGFloat) -> UIImage? {
        guard let image = self.cgImage else { return nil }

        let ciImage = CIImage(cgImage: image)
        guard let filter = CIFilter(name: "CIGaussianBlur") else {
            return nil
        }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(radius * 15, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let contextCI = CIContext()
        if let cgImage = contextCI.createCGImage(outputImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
}
