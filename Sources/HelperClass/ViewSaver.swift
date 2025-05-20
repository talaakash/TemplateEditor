//
//  ViewSaver.swift
//  Pods
//
//  Created by Akash Tala on 26/03/25.
//

public final class ViewSaver {
    public static let shared = ViewSaver()
    private init() {}
    
}

// MARK: - Public Methods
extension ViewSaver {
    public func getImageFromTemplate(from: UIViewController, with resolution: ImageResolution, contentSize: SaveContentSize, from view: UIView, showWaterMark: Bool = true) -> UIImage? {
        let duplicatedView = duplicateViewForSaving(in: from, contentSize: contentSize, from: view, showWaterMark: showWaterMark)
        let scale = resolution.scale
        let size = CGSize(width: duplicatedView.bounds.width * scale, height: duplicatedView.bounds.height * scale)
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            context.scaleBy(x: scale, y: scale)
            for subView in duplicatedView.subviews {
                if let draggableView = subView as? DraggableUIView {
                    context.saveGState()
                    
                    let originalTransform = draggableView.transform
                    
                    let scaleX = sqrt(originalTransform.a * originalTransform.a + originalTransform.c * originalTransform.c)
                    let scaleY = sqrt(originalTransform.b * originalTransform.b + originalTransform.d * originalTransform.d)
                    let translationX = originalTransform.tx
                    let translationY = originalTransform.ty
                    
                    var newTransform = CGAffineTransform.identity
                    newTransform = newTransform.translatedBy(x: translationX, y: translationY)
                    newTransform = newTransform.scaledBy(x: scaleX, y: scaleY)
                    
                    subView.transform = newTransform
                    
                    
                    let centerX = subView.frame.origin.x + (subView.frame.size.width / 2)
                    let centerY = subView.frame.origin.y + (subView.frame.size.height / 2)
                    context.translateBy(x: centerX, y: centerY)
                    
                    
                    let rotationAngle = atan2(originalTransform.b, originalTransform.a)
                    context.rotate(by: rotationAngle)
                    
                    context.translateBy(x: -(subView.frame.size.width / 2), y: -(subView.frame.size.height / 2))
                    
                    if draggableView.isLayered || draggableView.isBlurredView == true {
                        draggableView.drawHierarchy(in: subView.bounds, afterScreenUpdates: true)
                    } else {
                        subView.layer.render(in: context)
                    }
                    context.restoreGState()
                }
            }
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        duplicatedView.removeFromSuperview()
        return image
    }
    
    private func cloneView(_ view: DraggableUIView, scaleX: CGFloat, scaleY: CGFloat) -> DraggableUIView {
        if view.isLayered {
            return copyLayeredView(draggableView: view, scaleX: scaleX, scaleY: scaleY)
        }
        
        let clonedView = DraggableUIView()
        clonedView.componentType = view.componentType
        clonedView.layer.cornerRadius = view.layer.cornerRadius * min(scaleX, scaleY)
        clonedView.clipsToBounds = true
        clonedView.backgroundColor = view.backgroundColor
        clonedView.alpha = view.alpha
        
        let originalTransform = view.transform
        view.transform = .identity
        clonedView.frame = CGRect(x: view.frame.origin.x * scaleX, y: view.frame.origin.y * scaleY, width: view.frame.width * scaleX, height: view.frame.height * scaleY)
        clonedView.transform = originalTransform
        view.transform = originalTransform
        
        if let blendMode = view.layer.compositingFilter as? String {
            clonedView.layer.compositingFilter = blendMode
        }
        
        for subview in view.subviews {
            let clonedSubview: UIView
            
            if let imageView = subview as? UIImageView {
                let clonedImageView = UIImageView(image: imageView.image)
                clonedImageView.contentMode = imageView.contentMode
                clonedImageView.tintColor = imageView.tintColor
                clonedImageView.backgroundColor = .clear
                clonedSubview = clonedImageView
                clonedSubview.frame = CGRect(origin: .zero, size: clonedView.bounds.size)
                clonedSubview.transform = subview.transform
                
                let blurIntensity = view.blurIntensity
                if blurIntensity > 0 {
                    clonedView.originalImage = imageView.image
                }
                
                if view.layer.shadowOpacity > 0 {
                    clonedView.clipsToBounds = false
                    clonedSubview.layer.shadowColor = view.layer.shadowColor
                    clonedSubview.layer.shadowOpacity = view.layer.shadowOpacity
                    clonedSubview.layer.shadowRadius = view.layer.shadowRadius * scaleX
                    clonedSubview.layer.shadowOffset = CGSize(width: view.layer.shadowOffset.width * scaleX, height: view.layer.shadowOffset.height * scaleY)
                }
                
            } else if let label = subview as? UITextView {
                let clonedLabel = UITextView()
                clonedLabel.text = label.text
                clonedLabel.font = label.font!.withSize(label.font!.pointSize * scaleX)
                clonedLabel.textColor = label.textColor
                clonedLabel.textAlignment = label.textAlignment
                clonedLabel.backgroundColor = .clear
                clonedSubview = clonedLabel
                clonedSubview.frame = CGRect(origin: .zero, size: clonedView.bounds.size)
                clonedSubview.transform = subview.transform
                clonedLabel.centerTextVertically()
            } else if let menuBox = subview as? GridView {
                let gridView = GridView(frame: CGRect(origin: .zero, size: clonedView.bounds.size))
                gridView.menuStyle = menuBox.menuStyle
                gridView.columnWidth = menuBox.columnWidth * scaleX
                
                gridView.itemNameFontSize = menuBox.itemNameFontSize * scaleX
                gridView.itemDescriptionFontSize = menuBox.itemDescriptionFontSize * scaleX
                gridView.itemValueFontSize = menuBox.itemValueFontSize * scaleX
                gridView.columnWidth = menuBox.columnWidth * scaleX
                gridView.columnSpace = menuBox.columnSpace * scaleX
                
                gridView.itemNameFontStyle = menuBox.itemNameFontStyle
                gridView.itemDescriptionFontStyle = menuBox.itemDescriptionFontStyle
                gridView.itemValueFontStyle = menuBox.itemValueFontStyle
                
                gridView.data = menuBox.data
                gridView.headingColor = menuBox.headingColor
                gridView.descriptionColor = menuBox.descriptionColor
                gridView.valueColor = menuBox.valueColor
                clonedSubview = gridView
                clonedSubview.frame = CGRect(origin: .zero, size: clonedView.bounds.size)
                clonedSubview.transform = subview.transform
            } else {
                clonedSubview = UIView(frame: subview.frame)
            }
            clonedView.addSubview(clonedSubview)
        }
        
        return clonedView
    }
    
    func copyLayeredView(draggableView: DraggableUIView, scaleX: CGFloat, scaleY: CGFloat) -> DraggableUIView {
        let clonedView = DraggableUIView()
        clonedView.componentType = draggableView.componentType
        clonedView.layer.cornerRadius = draggableView.layer.cornerRadius * min(scaleX, scaleY)
        clonedView.clipsToBounds = true
        clonedView.backgroundColor = draggableView.backgroundColor
        clonedView.frame = CGRect(x: draggableView.frame.origin.x * scaleX, y: draggableView.frame.origin.y * scaleY, width: draggableView.frame.width * scaleX, height: draggableView.frame.height * scaleY)
        clonedView.transform = draggableView.transform
        clonedView.isRemovable = draggableView.isRemovable
        clonedView.isDuplicatable = draggableView.isDuplicatable
        clonedView.movable = draggableView.movable
        clonedView.isLayered = true
        
        for subView in draggableView.subviews {
            if let imageView = subView as? UIImageView {
                let newImageView = UIImageView()
                newImageView.contentMode = imageView.contentMode
                clonedView.addSubview(newImageView)
                newImageView.image = imageView.image
                newImageView.transform = imageView.transform
                newImageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    newImageView.topAnchor.constraint(equalTo: clonedView.topAnchor),
                    newImageView.bottomAnchor.constraint(equalTo: clonedView.bottomAnchor),
                    newImageView.leadingAnchor.constraint(equalTo: clonedView.leadingAnchor),
                    newImageView.trailingAnchor.constraint(equalTo: clonedView.trailingAnchor)
                ])
            } else if let draggableView = subView as? DraggableUIView {
                for subView in draggableView.subviews {
                    if let imageView = subView as? UIImageView {
                        var frame = imageView.frame
                        frame.size.width.scale(by: scaleX)
                        frame.size.height.scale(by: scaleY)
                        frame.origin.x.scale(by: scaleX)
                        frame.origin.y.scale(by: scaleY)
                        ViewManager.shared.addLayeredImage(in: clonedView, image: imageView.image, frame: frame)
                    }
                }
            }
        }
        
        return clonedView
    }
}

// MARK: - Private Methods
extension ViewSaver {
    private func duplicateViewForSaving(in vc: UIViewController, contentSize: SaveContentSize, from view: UIView, showWaterMark: Bool = true) -> UIView {
        let dynamicUIData = DynamicUIData(superViewWidth: view.bounds.width, superViewHeight: view.bounds.height, preview_img: "", outputWidth: (Float(view.bounds.width) * contentSize.rawValue), outputHeight: (Float(view.bounds.height) * contentSize.rawValue), elements: [:])
        
        let size = CGSize(width: CGFloat(dynamicUIData.outputWidth), height: CGFloat(dynamicUIData.outputHeight))
        
        let scaleX = size.width / view.bounds.width
        let scaleY = size.height / view.bounds.height
        
        var waterMarkView: DraggableUIView?
        if showWaterMark {
            if !isUserIsPaid {
                waterMarkView = self.getWaterMarkView(widthSize: view.bounds.width, heightSize: view.bounds.height)
                view.addSubview(waterMarkView!)
            }
        }
        let newView = UIView(frame: CGRect(origin: .zero, size: size))
        for subView in view.subviews {
            if let draggableView = subView as? DraggableUIView {
                let clonedSubview = cloneView(draggableView, scaleX: scaleX, scaleY: scaleY)
                newView.addSubview(clonedSubview)
            }
        }
        waterMarkView?.removeFromSuperview()
        vc.view.addSubview(newView)
        
        return newView
    }
    
    private func getWaterMarkView(widthSize: CGFloat, heightSize: CGFloat) -> DraggableUIView {
        let size = CGSize(width: 150, height: 50)
        let element = UIElement(type: ComponentType.label.rawValue, x: (widthSize / 2), y: ((heightSize - size.height) - 16), width: size.width, height: size.height, movable: nil, isUserInteractionEnabled: nil, alpha: 1, isDuplicatable: nil, isRemovable: nil, cornerRadius: nil, backGroundColor: nil, rotationAngle: 0, text: "Template Editor", alignment: nil, textColor: nil, fontURL: nil, size: nil, isEditable: nil, lineSpace: nil, letterSpace: nil, contentMode: nil, url: nil, itemNameFontSize: nil, itemDescriptionFontSize: nil, itemValueFontSize: nil, columnWidth: nil, columnSpace: 0, menuData: nil)
        
        let lblView = ViewManager.shared.createLabel(with: element, in: UIView(), fontFamily: UIFont(name: "RalewayRoman-Bold", size: 18)!, scaleX: 1, scaleY: 1)
        lblView.backgroundColor = Theme.primaryButtonColor
        lblView.cornerRadius = 10
        return lblView
    }
}
