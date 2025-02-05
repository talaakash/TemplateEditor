//
//  UIImagView_Extension.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import Kingfisher
import UIKit

//MARK: - KingFisher
extension UIImageView {
    func setImage(urlString: String, completionHandler: (() -> Void)? = nil) {
        if let image = UIImage(named: urlString) {
            self.image = image
            completionHandler?()
            return
        }
        
        guard let url = URL.init(string: urlString) else {
            return
        }
        if !url.isHosted() {
            self.image = StorageManager.shared.getImage(fileName: url.absoluteString)
            completionHandler?()
            return
        }
        
        let resource = KF.ImageResource(downloadURL: url, cacheKey: urlString)
        kf.indicatorType = .activity
        ImageCache.default.memoryStorage.config.totalCostLimit = 1
        kf.setImage(with: resource, options: [.diskCacheExpiration(.seconds(1800))], completionHandler: { retrievedImg in
            ImageCache.default.clearMemoryCache()
            completionHandler?()
        })
    }
    
    func enableZoom() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(startZooming(_:)))
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        
        doubleTapGesture.numberOfTapsRequired = 2
        isUserInteractionEnabled = true
        
        addGestureRecognizer(pinchGesture)
        addGestureRecognizer(doubleTapGesture)
        addGestureRecognizer(panGesture)
        
        pinchGesture.require(toFail: doubleTapGesture)
    }
    
    func disableZoom() {
        if let gestures = self.gestureRecognizers {
            for gesture in gestures {
                self.removeGestureRecognizer(gesture)
            }
        }
    }
    
    @objc private func startZooming(_ sender: UIPinchGestureRecognizer) {
        guard let view = sender.view, let superView = view.superview else { return }
        
        if sender.state == .began || sender.state == .changed {
            let scaleResult = view.transform.scaledBy(x: sender.scale , y: sender.scale )
            guard scaleResult.a > 1, scaleResult.d > 1 else { return }
            view.transform = scaleResult
            if view.frame.origin.x > 0 {
                view.frame.origin.x = -1
            }
            if view.frame.origin.y > 0 {
                view.frame.origin.y = -1
            }
            if view.frame.maxY < superView.frame.size.height {
                view.frame.origin.y = superView.frame.height - view.frame.height
            }
            if view.frame.maxX < superView.frame.size.width {
                view.frame.origin.x = superView.frame.width - view.frame.width
            }
            sender.scale = 1
        }
    }
    
    @objc private func handleDoubleTap(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view, let superView = view.superview else{return}
        if sender.state == .ended {
            if self.transform.a < 2{
                let scale: CGFloat = 2.0
                let newTransform = transform.scaledBy(x: scale, y: scale)
                let location = sender.location(in: view.superview)
                
                UIView.animate(withDuration: 0.3) {
                    self.transform = newTransform
                    self.frame.origin = location
                    let superViewHeight = superView.frame.height
                    let superViewWidth = superView.frame.width
                    
                    if location.x < (superViewWidth / 2) && location.y < (superViewHeight / 2){
                        if location.x <= (superViewWidth / 4) || location.y <= (superViewHeight / 4) {
                            self.frame.origin.x = 0
                            self.frame.origin.y = 0
                        }else{
                            self.doubleTapZoom(view: view, superView: superView, location: location)
                        }
                    }
                    else if location.x < (superViewWidth / 2) && location.y > (superViewHeight / 2){
                        if location.x <= (superViewWidth / 4) || location.y >= (superViewHeight / 4) + (superViewHeight / 2){
                            self.frame.origin.x = 0
                            self.frame.origin.y = superViewHeight - view.frame.height
                        }else{
                            self.doubleTapZoom(view: view, superView: superView, location: location)
                        }
                    }
                    else if location.x > (superViewWidth / 2) && location.y > (superViewHeight / 2){
                        if location.x >= (superViewWidth / 4) + (superViewWidth / 2)  || location.y >= (superViewHeight / 4) + (superViewHeight / 2){
                            self.frame.origin.x = superViewWidth - view.frame.width
                            self.frame.origin.y = superViewHeight - view.frame.height
                        }else{
                            self.doubleTapZoom(view: view, superView: superView, location: location)
                        }
                    }
                    else if location.x > (superViewWidth / 2) && location.y < (superViewHeight / 2){
                        if location.x >= (superViewWidth / 4) + (superViewWidth / 2) || location.y <= (superViewHeight / 4){
                            self.frame.origin.x = superViewWidth - view.frame.width
                            self.frame.origin.y = 0
                        }else{
                            self.doubleTapZoom(view: view, superView: superView, location: location)
                        }
                    }
                }
            }else{
                UIView.animate(withDuration: 0.3) {
                    view.transform = .identity
                    view.frame.origin.x = 0
                    view.frame.origin.y = 0
                }
            }
        }
    }
    private func doubleTapZoom(view : UIView,superView: UIView, location: CGPoint){
        view.frame.origin.y = (superView.center.y - (location.y * 2)) - superView.frame.origin.y
        view.frame.origin.x = (superView.center.x - (location.x * 2)) - superView.frame.origin.x
    }
    
    @objc private func handlePan(_ sender: UIPanGestureRecognizer) {
        
        guard let view = sender.view else { return }
        guard (sender.view?.superview) != nil else { return }
        
        let translation = sender.translation(in: view.superview)
        let newFrame = CGRect(x: view.frame.origin.x + translation.x,
                              y: view.frame.origin.y + translation.y,
                              width: view.frame.width,
                              height: view.frame.height)
        
        var isFrameValid = false
        guard let superView = view.superview else{return}
        if newFrame.minX > 0 {
            isFrameValid = true
        }
        if newFrame.maxX < superView.frame.width {
            isFrameValid = true
        }
        if newFrame.minY > 0 {
            isFrameValid = true
        }
        if newFrame.maxY < superView.frame.height {
            isFrameValid = true
        }
        if isFrameValid == false{
            view.center.x += translation.x
            view.center.y += translation.y
        }else{
            isFrameValid = false
        }
        sender.setTranslation(.zero, in: view.superview)
    }
}

extension URL {
    func isHosted() -> Bool {
        return self.scheme == "http" || self.scheme == "https"
    }
    
    func qrImage(withLogo logo: UIImage?) -> UIImage? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator"),
              let qrData = absoluteString.data(using: .ascii) else { return nil }
        
        qrFilter.setValue(qrData, forKey: "inputMessage")
        let qrTransform = CGAffineTransform(scaleX: 12, y: 12)
        guard let outputImage = qrFilter.outputImage?.transformed(by: qrTransform) else { return nil }
        
        let context = CIContext()
        guard let qrCGImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        let qrUIImage = UIImage(cgImage: qrCGImage)
        guard let logo = logo else { return qrUIImage }
        
        let qrSize = qrUIImage.size
        UIGraphicsBeginImageContextWithOptions(qrSize, false, 0.0)
        qrUIImage.draw(in: CGRect(origin: .zero, size: qrSize))
        
        let logoSize = CGSize(width: qrSize.width * 0.2, height: qrSize.height * 0.2) // 20% of QR size
        let logoOrigin = CGPoint(
            x: (qrSize.width - logoSize.width) / 2,
            y: (qrSize.height - logoSize.height) / 2
        )
        logo.draw(in: CGRect(origin: logoOrigin, size: logoSize))
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
    var qrImage: UIImage? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        let qrData = absoluteString.data(using: String.Encoding.ascii)
        qrFilter.setValue(qrData, forKey: "inputMessage")
        
        let qrTransform = CGAffineTransform(scaleX: 12, y: 12)
        let outputImg = qrFilter.outputImage?.transformed(by: qrTransform)
        
        let context = CIContext()
        guard let qrImage = context.createCGImage(outputImg!, from: outputImg!.extent) else { return nil }
        return UIImage(cgImage: qrImage)
    }
}
