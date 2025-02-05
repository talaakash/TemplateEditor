//
//  CIImage_Extension.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

import CoreImage

extension CIImage {
    
    func applyBrightness(_ brightness: CGFloat) -> CIImage? {
        let filter = CIFilter(name: "CIColorControls")!
        filter.setValue(self, forKey: kCIInputImageKey)
        filter.setValue(0.00025 * brightness, forKey: kCIInputBrightnessKey)
        filter.setValue(1.0, forKey: kCIInputSaturationKey)
        filter.setValue(1.0, forKey: kCIInputContrastKey)
        return filter.outputImage
    }
    
    func applyContrast(_ contrast: CGFloat) -> CIImage? {
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(self, forKey: kCIInputImageKey)
//        let contrastValue = contrast / 100.0  // 0.7 to 1.4
        filter?.setValue(mapValue(from: contrast), forKey: kCIInputContrastKey)
        return filter?.outputImage
    }
    
    private func mapValue(from value: CGFloat, oldMin: CGFloat = -100.0, oldMax: CGFloat = 100.0, newMin: CGFloat = 0.7, newMax: CGFloat = 1.4) -> CGFloat {
        return (value - oldMin) * (newMax - newMin) / (oldMax - oldMin) + newMin
    }
    
    func applySaturation(_ saturation: CGFloat) -> CIImage? {
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(self, forKey: kCIInputImageKey)
        let saturationValue = (saturation / 100.0) + 1.0 // Remap to 0 to 2
        filter?.setValue(saturationValue, forKey: kCIInputSaturationKey)
        return filter?.outputImage
    }
    
    func applyExposure(_ exposure: CGFloat) -> CIImage? {
        let filter = CIFilter(name: "CIExposureAdjust")
        filter?.setValue(self, forKey: kCIInputImageKey)
        let exposureValue = exposure / 100.0 // Remap to -1 to 1
        filter?.setValue(exposureValue, forKey: kCIInputEVKey)
        return filter?.outputImage
    }
    
    func applyBrilliancy(_ brilliancy: CGFloat) -> CIImage? {
        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(self, forKey: kCIInputImageKey)
        let brillianceValue = brilliancy / 1000.0 // Remap to -1 to 1 (same as brightness)
        filter?.setValue(brillianceValue, forKey: kCIInputBrightnessKey)
        return filter?.outputImage
    }
    
    func applyHighlight(_ highlight: CGFloat) -> CIImage? {
        let filter = CIFilter(name: "CIHighlightShadowAdjust")
        filter?.setValue(self, forKey: kCIInputImageKey)
        let highlightValue = (highlight + 100.0) / 200.0 // Remap to 0 to 1
        filter?.setValue(highlightValue, forKey: "inputHighlightAmount")
        return filter?.outputImage
    }
    
    func applyShadow(_ shadow: CGFloat) -> CIImage? {
        let filter = CIFilter(name: "CIHighlightShadowAdjust")
        filter?.setValue(self, forKey: kCIInputImageKey)
        let shadowValue = (shadow + 100.0) / 200.0 // Remap to 0 to 1
        filter?.setValue(shadowValue, forKey: "inputShadowAmount")
        return filter?.outputImage
    }
    
    func applyVibrance(_ vibrance: CGFloat) -> CIImage? {
        let filter = CIFilter(name: "CIVibrance")
        filter?.setValue(self, forKey: kCIInputImageKey)
        let vibranceValue = vibrance / 100.0 // Remap to -1 to 1
        filter?.setValue(vibranceValue, forKey: "inputAmount")
        return filter?.outputImage
    }
    
    func applyWarmth(_ warmth: CGFloat) -> CIImage? {
        let filter = CIFilter(name: "CITemperatureAndTint")
        filter?.setValue(self, forKey: kCIInputImageKey)
        let warmthValue = warmth / 100.0 * 2000.0 + 6500.0 // Remap to a color temperature range
        filter?.setValue(CIVector(x: warmthValue, y: 0), forKey: "inputNeutral")
        return filter?.outputImage
    }
    
    func applySharpness(_ sharpness: CGFloat) -> CIImage? {
        let filter = CIFilter(name: "CISharpenLuminance")
        filter?.setValue(self, forKey: kCIInputImageKey)
        let sharpnessValue = (sharpness / 10.0)
        filter?.setValue(sharpnessValue, forKey: kCIInputSharpnessKey)
        return filter?.outputImage
    }
    
    func applyVignette(_ vignette: CGFloat) -> CIImage? {
        let filter = CIFilter(name: "CIVignette")
        filter?.setValue(self, forKey: kCIInputImageKey)
        let vignetteValue = vignette / 100.0 // Remap to 0 to 1
        filter?.setValue(vignetteValue, forKey: kCIInputIntensityKey)
        filter?.setValue(30.0, forKey: kCIInputRadiusKey) // Fixed radius
        return filter?.outputImage
    }
}
