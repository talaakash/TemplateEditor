//
//  BGView.swift
//  Pods
//
//  Created by Admin on 16/05/25.
//

import UIKit

class BGView: DraggableUIView {

    private var imageView: UIImageView!
    
    var bgColor: UIColor? {
        get {
            if self.backgroundColor == .clear {
                return nil
            } else {
                return self.backgroundColor
            }
        }
        set {
            if let superview = self.superview {
                self.frame = superview.bounds
            }
            self.backgroundColor = newValue
            self.imageView.image = nil
        }
    }
    var image: UIImage? {
        get {
            return self.imageView.image
        }
        set {
            self.imageView.image = newValue
            self.backgroundColor = .clear
            self.setupImageView()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        doInitSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        doInitSetup()
    }
    
    
    private func doInitSetup() {
        self.backgroundColor = .white
        self.componentType = ComponentType.background.rawValue
        imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }
    
    private func setupImageView() {
        guard let image = self.imageView.image, let superview = self.superview else { return }
        
        let aspectRatio = image.size.height / image.size.width
        let maxAllowedHeight = superview.bounds.height
        var calculatedWidth = superview.bounds.width
        var calculatedHeight = calculatedWidth * aspectRatio

        if calculatedHeight > maxAllowedHeight {
            calculatedHeight = maxAllowedHeight
            calculatedWidth = calculatedHeight / aspectRatio
        }

        let superViewFrame = superview.frame
        let center = superview.center
        let originX = ((center.x - superViewFrame.origin.x) - (calculatedWidth / 2))
        let originY = ((center.y - superViewFrame.origin.y) - (calculatedHeight / 2))
        self.frame = CGRect(x: originX, y: originY, width: calculatedWidth, height: calculatedHeight)
    }
}
