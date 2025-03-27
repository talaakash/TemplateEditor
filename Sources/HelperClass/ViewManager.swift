//
//  ViewManager.swift
//  Pods
//
//  Created by Akash Tala on 25/03/25.
//

import UIKit

public final class ViewManager {
    public static let shared = ViewManager()
    var viewController: EditorViewController?
    private var widthSize: CGFloat = 200
    private var heightSize: CGFloat = 200
    private init() { }
    
}

// MARK: Public Methods
extension ViewManager {
    public func configureMainViewSize(view: UIView, dynamicData: DynamicUIData?, viewHeight: inout CGFloat, viewWidth: inout CGFloat) {
        guard let data = dynamicData else { return }

        let aspectRatio = data.superViewHeight / data.superViewWidth
        let maxAllowedHeight = view.bounds.height
        var calculatedWidth = view.bounds.width
        var calculatedHeight = calculatedWidth * aspectRatio

        if calculatedHeight > maxAllowedHeight {
            calculatedHeight = maxAllowedHeight
            calculatedWidth = calculatedHeight / aspectRatio
        }

        self.widthSize = calculatedWidth
        self.heightSize = calculatedHeight
        viewHeight = calculatedHeight
        viewWidth = calculatedWidth
    }
    
    public func configureData(in view: UIView, data: [UIElement], scaleX: CGFloat, scaleY: CGFloat) {
        for (index, element) in data.enumerated() {
            switch element.type {
            case ComponentType.label.rawValue:
                if let fontURL = element.fontURL {
                    self.downloadAndApplyFont(from: fontURL) { fontName in
                        guard let fontName else { return }
                        if let font = UIFont(name: fontName, size: (element.size ?? 18) * min(scaleX, scaleY)) {
                            let _ = self.createLabel(with: element, in: view, fontFamily: font, scaleX: scaleX, scaleY: scaleY)
                        } else {
                            let font = UIFont.systemFont(ofSize: CGFloat(element.size ?? 18) * min(scaleX, scaleY))
                            let _ = self.createLabel(with: element, in: view, fontFamily: font, scaleX: scaleX, scaleY: scaleY)
                        }
                    }
                } else {
                    let font = UIFont.systemFont(ofSize: CGFloat(element.size ?? 18) * min(scaleX, scaleY))
                    let _ = self.createLabel(with: element, in: view, fontFamily: font, scaleX: scaleX, scaleY: scaleY)
                }
            case ComponentType.image.rawValue:
                self.createImageView(with: element, in: view, scaleX: scaleX, scaleY: scaleY, isBgImg: index == 0 ? true : false)
            case ComponentType.menuBox.rawValue:
                self.createMenuView(with: element, in: view, scaleX: scaleX, scaleY: scaleY)
            case ComponentType.shape.rawValue:
                self.createShapeView(with: element, in: view, scaleX: scaleX, scaleY: scaleY)
            default:
                break
            }
        }
    }
}

// MARK: View adding methods
extension ViewManager {
    private func createShapeView(with element: UIElement, in view: UIView, scaleX: CGFloat, scaleY: CGFloat) {
        let draggableShapeView = DraggableUIView()
        configureDraggableView(draggableShapeView, with: element, scaleX: scaleX, scaleY: scaleY)
        
        let shapeView = UIImageView()
        shapeView.tintColor = .white
        shapeView.contentMode = .scaleToFill
        shapeView.tintAdjustmentMode = .normal
        shapeView.translatesAutoresizingMaskIntoConstraints = false
        if let urlString = element.url {
            shapeView.setImage(urlString: urlString)
            shapeView.stringTag = urlString
            draggableShapeView.originalImage = shapeView.image
        }
        if let tintColor = element.tintColor, let tintColor = UIColor(hex: tintColor) {
            shapeView.tintColor = tintColor
            shapeView.image = shapeView.image
        }
        draggableShapeView.addSubview(shapeView)
        setConstraints(for: shapeView, in: draggableShapeView)
        
        if let blurAlpha = element.blurAlpha {
            draggableShapeView.blurIntensity = blurAlpha
            draggableShapeView.originalImage = shapeView.image
        }
        
        viewController?.addGesture(draggableShapeView)
        view.addSubview(draggableShapeView)
    }
    
    private func createMenuView(with element: UIElement, in view: UIView, scaleX: CGFloat, scaleY: CGFloat) {
        let draggableMenuView = DraggableUIView()
        configureDraggableView(draggableMenuView, with: element, scaleX: scaleX, scaleY: scaleY)
        
        let gridView = GridView(frame: .zero)
        gridView.menuStyle = MenuStyle(rawValue: element.menuStyle ?? 1) ?? .type1
        self.applyMenuContent(for: gridView, element: element, scaleX: 1, scaleY: 1)
        gridView.data = element.menuData ?? []
        gridView.translatesAutoresizingMaskIntoConstraints = false
        draggableMenuView.addSubview(gridView)
        setConstraints(for: gridView, in: draggableMenuView)
        view.addSubview(draggableMenuView)
        self.applyMenuContent(for: gridView, element: element, scaleX: scaleX, scaleY: scaleY)
        viewController?.addGesture(draggableMenuView)
    }
    
    private func createImageView(with element: UIElement, in view: UIView, scaleX: CGFloat, scaleY: CGFloat, isBgImg: Bool = false) {
        let draggableImageView = DraggableUIView()
        configureDraggableView(draggableImageView, with: element, scaleX: scaleX, scaleY: scaleY)
        
        draggableImageView.isBgImg = isBgImg
        
        var originalImage: UIImage?
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let urlString = element.url {
            imageView.setImage(urlString: urlString, completionHandler: { [weak self] in
                originalImage = imageView.image
                draggableImageView.originalImage = originalImage
                if element.isLayeredImg ?? false {
                    draggableImageView.isLayered = true
                    self?.addLayeredImage(in: draggableImageView)
                }
                if let blurAlpha = element.blurAlpha {
                    draggableImageView.blurIntensity = blurAlpha
                    draggableImageView.originalImage = originalImage
                }
            })
        }
        imageView.contentMode = UIView.ContentMode(rawValue: element.contentMode ?? 1) ?? .scaleAspectFit
        draggableImageView.addSubview(imageView)
        setConstraints(for: imageView, in: draggableImageView)
        
        if let originalImage {
            if let blurAlpha = element.blurAlpha {
                draggableImageView.blurIntensity = blurAlpha
                draggableImageView.originalImage = originalImage
            }
        }
        
        viewController?.addGesture(draggableImageView)
        view.addSubview(draggableImageView)
    }
    
    private func applyMenuContent(for gridView: GridView, element: UIElement, scaleX: CGFloat, scaleY: CGFloat) {
        gridView.columnWidth = ((element.columnWidth ?? 30) * min(scaleX, scaleY))
        gridView.columnSpace = ((element.columnSpace ?? 0) * min(scaleX, scaleY))
        if let colorCode = element.itemNameTextColor, let color = UIColor(hex: colorCode) {
            gridView.headingColor = color
        }
        if let colorCode = element.itemDescriptionTextColor, let color = UIColor(hex: colorCode) {
            gridView.descriptionColor = color
        }
        if let colorCode = element.itemValueTextColor, let color = UIColor(hex: colorCode) {
            gridView.valueColor = color
        }
        gridView.itemNameFontSize = ((element.itemNameFontSize ?? 19) * min(scaleX, scaleY))
        gridView.itemDescriptionFontSize = ((element.itemDescriptionFontSize ?? 17) * min(scaleX, scaleY))
        gridView.itemValueFontSize = ((element.itemValueFontSize ?? 17) * min(scaleX, scaleY))
        
        if let font = UIFont(name: element.itemNameFontStyle ?? "", size: gridView.itemNameFontSize) {
            gridView.itemNameFontStyle = font
        }
        if let font = UIFont(name: element.itemDescriptionFontStyle ?? "", size: gridView.itemDescriptionFontSize) {
            gridView.itemDescriptionFontStyle = font
        }
        if let font = UIFont(name: element.itemValueFontStyle ?? "", size: gridView.itemValueFontSize) {
            gridView.itemValueFontStyle = font
        }
    }
    
    func addLayeredImage(in view: DraggableUIView, image: UIImage? = nil, frame: CGRect? = nil) {
        let newImageView = UIImageView()
        newImageView.contentMode = .scaleAspectFit
        newImageView.backgroundColor = .white
        
        let draggableView = DraggableUIView()
        draggableView.componentType = ComponentType.image.rawValue
        if let imageView = view.subviews.first as? UIImageView {
            imageView.isUserInteractionEnabled = false
            draggableView.frame = CGRect(origin: .zero, size: view.frame.size)
            let layer = CALayer()
            layer.frame = draggableView.layer.frame
            let maskImg = extractWhiteAreas(from: imageView.image ?? UIImage())?.cgImage
            layer.contents = maskImg
            draggableView.layer.mask = layer
        }
        
        draggableView.addSubview(newImageView)
        newImageView.frame = draggableView.bounds
        viewController?.addGesture(draggableView)
        view.addSubview(draggableView)
        view.movable = false
        draggableView.movable = false
        newImageView.enableZoom()
        
        newImageView.image = image
        if let frame {
            newImageView.frame = frame
        }
    }
    
    func createLabel(with element: UIElement, in view: UIView, fontFamily: UIFont, scaleX: CGFloat, scaleY: CGFloat) -> DraggableUIView {
        let draggableLabelView = DraggableUIView()
        configureDraggableView(draggableLabelView, with: element, scaleX: scaleX, scaleY: scaleY)
        
        let txtView = UITextView()
        txtView.text = element.text ?? "Text"
        txtView.textColor = UIColor(hex: element.textColor ?? "#000000")
        txtView.textAlignment = NSTextAlignment(rawValue: element.alignment ?? 1) ?? .center
        txtView.font = fontFamily
        txtView.backgroundColor = .clear
        txtView.isEditable = false
        txtView.isSelectable = false
        txtView.isScrollEnabled = false
        txtView.translatesAutoresizingMaskIntoConstraints = false
        draggableLabelView.addSubview(txtView)
        setConstraints(for: txtView, in: draggableLabelView)
        
        viewController?.addGesture(draggableLabelView)
        view.addSubview(draggableLabelView)
        return draggableLabelView
    }
}

// MARK: Utility Methods
extension ViewManager {
    private func extractWhiteAreas(from image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        // Create a raw buffer to store pixel data
        var rawData = [UInt8](repeating: 0, count: height * bytesPerRow)
        
        // Create context for pixel manipulation
        guard let context = CGContext(data: &rawData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        // Draw the image into the context to extract the pixel data
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        
        // Loop through each pixel and modify alpha if the pixel is white
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * bytesPerRow) + (x * bytesPerPixel)
                
                let red = rawData[pixelIndex]
                let green = rawData[pixelIndex + 1]
                let blue = rawData[pixelIndex + 2]
                
                // Check if the pixel is white (with some tolerance)
                if red > 240 && green > 240 && blue > 240 {
                    // Keep this pixel fully opaque
                    rawData[pixelIndex + 3] = 255 // Set alpha to 1
                } else {
                    // Make this pixel fully transparent
                    rawData[pixelIndex + 3] = 0 // Set alpha to 0
                }
            }
        }
        
        // Create a new image from the modified pixel data
        guard let newCgImage = context.makeImage() else { return nil }
        
        return UIImage(cgImage: newCgImage)
    }
    
    private func configureDraggableView(_ view: DraggableUIView, with element: UIElement, scaleX: CGFloat, scaleY: CGFloat) {
        view.frame = CGRect(
            x: element.x * scaleX,
            y: element.y * scaleY,
            width: element.width * scaleX,
            height: element.height * scaleY
        )
        view.componentType = element.type
        view.movable = element.movable ?? true
        view.isRemovable = element.isRemovable ?? true
        view.isEditable = element.isEditable ?? true
        view.isDuplicatable = element.isDuplicatable ?? true
        view.isUserInteractionEnabled = element.isUserInteractionEnabled ?? true //c
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        view.translatesAutoresizingMaskIntoConstraints = true
        if let rotationAngle = element.rotationAngle {
            view.transform = view.transform.rotated(by: rotationAngle)
        }
        
        if let blendMode = element.blendMode {
            view.layer.compositingFilter = blendMode
        }
        
        view.layer.shadowColor = UIColor.black.cgColor
        if let opacity = element.shadowOpacity {
            view.layer.shadowOpacity = opacity
        }
        if let radius = element.shadowRadius {
            view.layer.shadowRadius = radius
        }
        if let widthOffset = element.shadowOffsetWidth, let heightOffset = element.shadowOffsetHeight {
            view.layer.shadowOffset = CGSize(width: widthOffset, height: heightOffset)
        }
        
        if let bgColorHex = element.backGroundColor, !bgColorHex.isEmpty {
            view.backgroundColor = UIColor(hex: bgColorHex)
        } else {
            view.backgroundColor = UIColor.clear
        }
        if let cornerRadius = element.cornerRadius {
            view.layer.cornerRadius = CGFloat(cornerRadius) * min(scaleX, scaleY)
            view.clipsToBounds = true
        }
    }
    
    private func setConstraints(for subview: UIView, in container: UIView) {
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            subview.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
            subview.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            subview.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
        ])
    }
    
    private func downloadAndApplyFont(from urlStringOrFontName: String, completion: @escaping (String?) -> Void) {
        // Check if the string is a valid URL
        if let url = URL(string: urlStringOrFontName), UIApplication.shared.canOpenURL(url) {
            // It's a URL, proceed to download and apply the font
            self.downloadFont(from: url, completion: completion)
        } else {
            // It's not a URL, assume it's a font name and check locally
            let fontName = urlStringOrFontName
            
            // Check if the font exists locally
            if UIFont(name: fontName, size: 12) != nil {
                // Font exists, return the font name
                completion(fontName)
            } else {
                // Font does not exist locally
                completion(nil)
            }
        }
    }
    
    private func downloadFont(from url: URL, completion: @escaping (String?) -> Void) {
        let fontName = url.lastPathComponent.replacingOccurrences(of: ".ttf", with: "")
        let fontFileURL = self.getLocalFontURL(for: fontName)
        
        if FileManager.default.fileExists(atPath: fontFileURL.path) {
            do {
                let fontData = try Data(contentsOf: fontFileURL)
                if let registeredFontName = FontManager.registerFont(with: fontData) {
                    DispatchQueue.main.async {
                        FontManager.customFonts.append(registeredFontName)
                        FontManager.fontStyles.append(registeredFontName)
                        completion(registeredFontName)
                    }
                }
                return
            } catch {
                debugPrint("Error reading font file: \(error)")
                completion(nil)
                return
            }
        }
        
        URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL, error == nil else {
                debugPrint("Error downloading font: \(String(describing: error))")
                completion(nil)
                return
            }
            
            do {
                try FileManager.default.moveItem(at: tempURL, to: fontFileURL)
                let fontData = try Data(contentsOf: fontFileURL)
                if let registeredFontName = FontManager.registerFont(with: fontData) {
                    DispatchQueue.main.async {
                        FontManager.customFonts.append(registeredFontName)
                        FontManager.fontStyles.append(registeredFontName)
                        completion(registeredFontName)
                    }
                } else {
                    completion(nil)
                }
            } catch {
                debugPrint("Error moving or reading font file: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    func getLocalFontURL(for fontName: String) -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("\(fontName).ttf")
    }
}
