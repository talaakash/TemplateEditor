//
//  EditorViewModel.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import Foundation
import UIKit

protocol EditorViewModelDelegate: AnyObject {
    func didUpdateSelectedView(_ selectedView: DraggableUIView?)
    func willUpdateSelectedView(_ selectedView: DraggableUIView?)
    func adjustLayerOptionSelected(adjustBtn: UIView)
    func deleteViewBtnTapped(view: UIView)
    func checkUndoRedoAvailable()
}

class EditorViewModel {
    weak var delegate: EditorViewModelDelegate?
    
    var dynamicUIData: DynamicUIData?
    weak var selectedView: DraggableUIView? {
        didSet {
            openedView?.remove(complete: {
                self.controllerView.isHidden = false
                self.openedView = nil
            })
            controllerView.removeFromSuperview()
            self.attachControllerToView()
            delegate?.didUpdateSelectedView(selectedView)
        }
        willSet {
            delegate?.willUpdateSelectedView(selectedView)
        }
    }
    var controllerView: UIView!
    weak var openedView: UIView? {
        didSet {
            if openedView != nil {
                self.editOptionView?.isHidden = true
                self.componentCollection?.isHidden = true
            } else {
                self.editOptionView?.isHidden = false
                self.componentCollection?.isHidden = false
            }
        }
    }
    weak var editOptionView: UIView?
    weak var componentCollection: UIView?
    
    var menuData: [MenuItemDetails] = [
        MenuItemDetails(itemName: "Margherita", description: "Tomato sauce, mozzarella, basil", values: ["1": "$2", "2": "$5", "3": "$7"]),
        MenuItemDetails(itemName: "Pepperoni", description: "Tomato sauce, mozzarella, pepperoni", values: ["1": "$5","2": "$5", "3": "$7"]),
        MenuItemDetails(itemName: "Hawaiian", description: "Tomato sauce, mozzarella, ham, pineapple", values: ["1": "$7", "2": "$8", "3": "$9"]),
        MenuItemDetails(itemName: "Four Cheese", description: "Tomato sauce, mozzarella, parmesan, gorgonzola, provolone", values: ["1": "$1","2": "$1","3": "$1"]),
        MenuItemDetails(itemName: "Mediterranean", description: "Olive oil, mozzarella, feta, olives, artichokes, spinach", values: ["1": "$1", "2": "$1", "3": "$1"])
    ]
    
    var menuData4: [MenuItemDetails] = [
        MenuItemDetails(itemName: "Combo 1", description: "Stuffed Mushrooms Roast Turkey", values: ["1": "$32"]),
        MenuItemDetails(itemName: "Combo 2", description: "Stuffed Mushrooms Roast Turkey", values: ["1": "$32"]),
        MenuItemDetails(itemName: "Combo 3", description: "Stuffed Mushrooms Roast Turkey", values: ["1": "$32"])
    ]
    
    var menuData6: [MenuItemDetails] = [
        MenuItemDetails(itemName: "Margherita", description: "Tomato sauce", values: ["1": "$2", "2": "$5", "3": "$7"]),
        MenuItemDetails(itemName: "Pepperoni", description: "Tomato sauce", values: ["1": "$5","2": "$5", "3": "$7"]),
        MenuItemDetails(itemName: "Hawaiian", description: "Tomato sauce", values: ["1": "$7", "2": "$8", "3": "$9"]),
        MenuItemDetails(itemName: "Four Cheese", description: "Tomato sauce", values: ["1": "$1","2": "$1","3": "$1"]),
        MenuItemDetails(itemName: "Mediterranean", description: "Olive oil,", values: ["1": "$1", "2": "$1", "3": "$1"])
    ]
    
    var menuData7: [MenuItemDetails] = [
        MenuItemDetails(itemName: "Vanila Milkshake", description: "Tomato sauce, mozzarella, basil", values: ["1": "200ml", "2": "$25"]),
        MenuItemDetails(itemName: "Chocolate Milkshake", description: "Tomato sauce, mozzarella, pepperoni", values: ["1": "200ml", "2": "$30"]),
        MenuItemDetails(itemName: "Strawberry Milkshake", description: "Tomato sauce, mozzarella, ham, pineapple", values: ["1": "200ml", "2": "$35"])
    ]
    
    var menuData10: [MenuItemDetails] = [
        MenuItemDetails(itemName: "Margherita", values: ["1": "S $2", "2": "M $5", "3": "L $7"]),
        MenuItemDetails(itemName: "Pepperoni", values: ["1": "S $5","2": "M $5", "3": "L $7"]),
        MenuItemDetails(itemName: "Hawaiian", values: ["1": "S $7", "2": "M $8", "3": "L $9"])
    ]
    
    var editOptions: [GenericModel<EditType>] {
        return getSelectedViewEditOptions()
    }

    // Configure main view's aspect ratio and dimensions
    func configureMainViewSize(view: UIView, viewHeight: inout CGFloat, viewWidth: inout CGFloat) {
        guard let data = dynamicUIData else { return }

        let aspectRatio = data.superViewHeight / data.superViewWidth
        let maxAllowedHeight = view.bounds.height
        var calculatedWidth = view.bounds.width
        var calculatedHeight = calculatedWidth * aspectRatio

        if calculatedHeight > maxAllowedHeight {
            calculatedHeight = maxAllowedHeight
            calculatedWidth = calculatedHeight / aspectRatio
        }

        viewHeight = calculatedHeight
        viewWidth = calculatedWidth
    }

    private func getSelectedViewEditOptions() -> [GenericModel<EditType>] {
        guard let selectedView = selectedView else { return [] }

        var options: [GenericModel<EditType>] = []
        let availableOptions = EditController.editOptions
        
        guard let componentName = selectedView.componentType, let componentType = ComponentType(rawValue: componentName) else { return options }
        
        switch componentType {
        case .label:
            if selectedView.isEditable != false, let option = availableOptions.first(where: { $0.type == .editFont }) {
                options.append(option)
            }
        case .image:
            if selectedView.isEditable != false {
                if let option = availableOptions.first(where: { $0.type == .change }) {
                    options.append(option)
                }
//                This feature is not for MenuMaker
//                if let option = availableOptions.first(where: { $0.type == .layered }) {
//                    options.append(option)
//                }
            }
        case .menuBox:
            if let option = availableOptions.first(where: { $0.type == .editContent }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .changeSize }) {
                options.append(option)
            }
            let columnMenuStyles: [MenuStyle] = [.type1, .type2, .type3, .type6, .type9, .type12, .type13]
            if let gridView = selectedView.subviews.compactMap({ $0 as? GridView }).first {
                if columnMenuStyles.contains(where: { gridView.menuStyle == $0 }), let option = availableOptions.first(where: { $0.type == .adjustSpace }) {
                    options.append(option)
                }
            }
        case .shape:
            if selectedView.isEditable != false, let option = availableOptions.first(where: { $0.type == .change }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .flipH }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .flipV }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .tintColor }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .blur }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .opacity }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .shadow }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .blendImage }) {
                options.append(option)
            }
        default:
            break
        }
        
        if selectedView.isUserInteractionEnabled {
            if selectedView.movable != false, let option = availableOptions.first(where: { $0.type == .move }) {
                options.append(option)
            }
            if let parentDraggable = selectedView.superview as? DraggableUIView, parentDraggable.isLayered {
                options.removeAll(where: { $0.type == .move })
            }
        }
        
        if componentType == .label {
            if let option = availableOptions.first(where: { $0.type == .fontChange }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .fontSize }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .fontColor }) {
                options.append(option)
            }
        }
        
        if componentType == .image {
            if let option = availableOptions.first(where: { $0.type == .flipH }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .flipV }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .crop }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .adjustments }) {
                options.append(option)
            }
            if !selectedView.isEditable {
                options.removeAll(where: { $0.type == .crop })
            }
        }
        
        if componentType != .shape, let option = availableOptions.first(where: { $0.type == .backgroundColor }) {
            options.append(option)
        }
        
        if componentType == .image {
            if let option = availableOptions.first(where: { $0.type == .blur }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .opacity }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .shadow }) {
                options.append(option)
            }
            if let option = availableOptions.first(where: { $0.type == .blendImage }) {
                options.append(option)
            }
        }
        
        if selectedView.isDuplicatable != false, let option = availableOptions.first(where: { $0.type == .copy }) {
            options.append(option)
        }
        
        if isUserIsAdmin, let option = availableOptions.first(where: { $0.type == .lock }) {
            options.append(option)
        }
        
        return options
    }
    
    func downloadFont(from url: URL, completion: @escaping (String?) -> Void) {
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

extension EditorViewModel {
    func setupController() {
        let tapAreaInset:CGFloat = 8
        controllerView = UIView()
        controllerView.backgroundColor = UIColor.clear
        
        let borderView = UIView()
        borderView.backgroundColor = UIColor.clear
        borderView.layer.borderColor = UIColor.white.cgColor
        borderView.layer.borderWidth = 1
        borderView.layer.shouldRasterize = true
        borderView.layer.rasterizationScale = UIScreen.main.scale
        borderView.translatesAutoresizingMaskIntoConstraints = false
        controllerView.addSubview(borderView)
        NSLayoutConstraint.activate([
            borderView.leadingAnchor.constraint(equalTo: controllerView.leadingAnchor, constant: 20),
            borderView.trailingAnchor.constraint(equalTo: controllerView.trailingAnchor, constant: -20),
            borderView.topAnchor.constraint(equalTo: controllerView.topAnchor, constant: 20),
            borderView.bottomAnchor.constraint(equalTo: controllerView.bottomAnchor, constant: -20)
        ])
        
        let bottomEdgeController = UIView()
        bottomEdgeController.backgroundColor = .clear
        bottomEdgeController.translatesAutoresizingMaskIntoConstraints = false
        self.controllerView.addSubview(bottomEdgeController)
        let bottomEdgeView = UIView()
        bottomEdgeView.backgroundColor = UIColor(named: "borderColorF5C000", in: packageBundle, compatibleWith: nil)
        bottomEdgeView.layer.cornerRadius = 3.5
        bottomEdgeView.layer.borderWidth = 1
        bottomEdgeView.layer.borderColor = UIColor.black.cgColor
        bottomEdgeController.addSubview(bottomEdgeView)
        bottomEdgeController.tag = EdgeController.bottomOnly.rawValue
        bottomEdgeView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bottomEdgeView.widthAnchor.constraint(equalToConstant: 14),
            bottomEdgeView.heightAnchor.constraint(equalToConstant: 7),
            bottomEdgeView.leadingAnchor.constraint(equalTo: bottomEdgeController.leadingAnchor, constant: tapAreaInset),
            bottomEdgeView.trailingAnchor.constraint(equalTo: bottomEdgeController.trailingAnchor, constant: -tapAreaInset),
            bottomEdgeView.topAnchor.constraint(equalTo: bottomEdgeController.topAnchor, constant: tapAreaInset),
            bottomEdgeView.bottomAnchor.constraint(equalTo: bottomEdgeController.bottomAnchor, constant: -tapAreaInset)
        ])
        NSLayoutConstraint.activate([
            bottomEdgeController.centerXAnchor.constraint(equalTo: self.controllerView.centerXAnchor),
            bottomEdgeController.bottomAnchor.constraint(equalTo: self.controllerView.bottomAnchor, constant: -9)
        ])
        GestureManager.shared.addPanGesture(to: bottomEdgeController, target: self, action: #selector(handleResize(_:)))
        
        let rightEdgeController = UIView()
        rightEdgeController.backgroundColor = .clear
        rightEdgeController.translatesAutoresizingMaskIntoConstraints = false
        self.controllerView.addSubview(rightEdgeController)
        let rightEdge = UIView()
        rightEdgeController.addSubview(rightEdge)
        rightEdge.backgroundColor = UIColor(named: "borderColorF5C000", in: packageBundle, compatibleWith: nil)
        rightEdge.layer.cornerRadius = 3.5
        rightEdge.layer.borderWidth = 1
        rightEdge.layer.borderColor = UIColor.black.cgColor
        rightEdge.isUserInteractionEnabled = true
        rightEdgeController.tag = EdgeController.rightOnly.rawValue
        rightEdge.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rightEdge.widthAnchor.constraint(equalToConstant: 7),
            rightEdge.heightAnchor.constraint(equalToConstant: 28),
            rightEdge.leadingAnchor.constraint(equalTo: rightEdgeController.leadingAnchor, constant: tapAreaInset),
            rightEdge.trailingAnchor.constraint(equalTo: rightEdgeController.trailingAnchor, constant: -tapAreaInset),
            rightEdge.topAnchor.constraint(equalTo: rightEdgeController.topAnchor, constant: tapAreaInset),
            rightEdge.bottomAnchor.constraint(equalTo: rightEdgeController.bottomAnchor, constant: -tapAreaInset)
        ])
        NSLayoutConstraint.activate([
            rightEdgeController.centerYAnchor.constraint(equalTo: controllerView.centerYAnchor),
            rightEdgeController.trailingAnchor.constraint(equalTo: controllerView.trailingAnchor, constant: -9)
        ])
        GestureManager.shared.addPanGesture(to: rightEdgeController, target: self, action: #selector(handleResize(_:)))
        
        let resizeBoxController = UIView()
        resizeBoxController.backgroundColor = .clear
        resizeBoxController.translatesAutoresizingMaskIntoConstraints = false
        self.controllerView.addSubview(resizeBoxController)
        let resizeBox = UIImageView(image: UIImage(named: "resize", in: packageBundle, with: nil))
        resizeBoxController.addSubview(resizeBox)
        resizeBox.isUserInteractionEnabled = true
        resizeBoxController.tag = EdgeController.free.rawValue
        resizeBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            resizeBox.widthAnchor.constraint(equalToConstant: 24),
            resizeBox.heightAnchor.constraint(equalToConstant: 24),
            resizeBox.topAnchor.constraint(equalTo: resizeBoxController.topAnchor, constant: tapAreaInset),
            resizeBox.leadingAnchor.constraint(equalTo: resizeBoxController.leadingAnchor, constant: tapAreaInset),
            resizeBox.trailingAnchor.constraint(equalTo: resizeBoxController.trailingAnchor, constant: -tapAreaInset),
            resizeBox.bottomAnchor.constraint(equalTo: resizeBoxController.bottomAnchor, constant: -tapAreaInset)
        ])
        NSLayoutConstraint.activate([
            resizeBoxController.trailingAnchor.constraint(equalTo: self.controllerView.trailingAnchor),
            resizeBoxController.bottomAnchor.constraint(equalTo: self.controllerView.bottomAnchor)
        ])
        GestureManager.shared.addPanGesture(to: resizeBoxController, target: self, action: #selector(handleResize(_:)))
        
        let closeController = UIView()
        closeController.backgroundColor = .clear
        closeController.translatesAutoresizingMaskIntoConstraints = false
        self.controllerView.addSubview(closeController)
        let closeBox = UIImageView(image: UIImage(named: "deleteComponent", in: packageBundle, with: nil))
        closeController.addSubview(closeBox)
        closeBox.isUserInteractionEnabled = true
        closeBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            closeBox.widthAnchor.constraint(equalToConstant: 24),
            closeBox.heightAnchor.constraint(equalToConstant: 24),
            closeBox.topAnchor.constraint(equalTo: closeController.topAnchor, constant: tapAreaInset),
            closeBox.leadingAnchor.constraint(equalTo: closeController.leadingAnchor, constant: tapAreaInset),
            closeBox.trailingAnchor.constraint(equalTo: closeController.trailingAnchor, constant: -tapAreaInset),
            closeBox.bottomAnchor.constraint(equalTo: closeController.bottomAnchor, constant: -tapAreaInset)
        ])
        NSLayoutConstraint.activate([
            closeController.leadingAnchor.constraint(equalTo: self.controllerView.leadingAnchor),
            closeController.topAnchor.constraint(equalTo: self.controllerView.topAnchor)
        ])
        GestureManager.shared.addTapGesture(to: closeController, target: self, action: #selector(deleteView(_:)))
        
        let rotationBoxController = UIView()
        rotationBoxController.backgroundColor = .clear
        rotationBoxController.translatesAutoresizingMaskIntoConstraints = false
        self.controllerView.addSubview(rotationBoxController)
        let rotationBox = UIImageView(image: UIImage(named: "rotate", in: packageBundle, with: nil))
        rotationBoxController.addSubview(rotationBox)
        rotationBox.isUserInteractionEnabled = true
        rotationBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rotationBox.widthAnchor.constraint(equalToConstant: 24),
            rotationBox.heightAnchor.constraint(equalToConstant: 24),
            rotationBox.leadingAnchor.constraint(equalTo: rotationBoxController.leadingAnchor, constant: tapAreaInset),
            rotationBox.trailingAnchor.constraint(equalTo: rotationBoxController.trailingAnchor, constant: -tapAreaInset),
            rotationBox.topAnchor.constraint(equalTo: rotationBoxController.topAnchor, constant: tapAreaInset),
            rotationBox.bottomAnchor.constraint(equalTo: rotationBoxController.bottomAnchor, constant: -tapAreaInset)
        ])
        NSLayoutConstraint.activate([
            rotationBoxController.leadingAnchor.constraint(equalTo: controllerView.leadingAnchor),
            rotationBoxController.bottomAnchor.constraint(equalTo: controllerView.bottomAnchor)
        ])
        GestureManager.shared.addPanGesture(to: rotationBoxController, target: self, action: #selector(handleRotation(_:)))
        
        let layerBoxController = UIView()
        layerBoxController.backgroundColor = .clear
        layerBoxController.translatesAutoresizingMaskIntoConstraints = false
        self.controllerView.addSubview(layerBoxController)
        let layerBox = UIImageView(image: UIImage(named: "layerAdjust", in: packageBundle, with: nil))
        layerBoxController.addSubview(layerBox)
        layerBox.isUserInteractionEnabled = true
        layerBox.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            layerBox.widthAnchor.constraint(equalToConstant: 24),
            layerBox.heightAnchor.constraint(equalToConstant: 24),
            layerBox.trailingAnchor.constraint(equalTo: layerBoxController.trailingAnchor, constant: -tapAreaInset),
            layerBox.topAnchor.constraint(equalTo: layerBoxController.topAnchor, constant: tapAreaInset),
            layerBox.bottomAnchor.constraint(equalTo: layerBoxController.bottomAnchor, constant: -tapAreaInset),
            layerBox.leadingAnchor.constraint(equalTo: layerBoxController.leadingAnchor, constant: tapAreaInset)
        ])
        NSLayoutConstraint.activate([
            layerBoxController.trailingAnchor.constraint(equalTo: controllerView.trailingAnchor),
            layerBoxController.topAnchor.constraint(equalTo: controllerView.topAnchor)
        ])
        GestureManager.shared.addTapGesture(to: layerBoxController, target: self, action: #selector(adjustLayer(_:)))
        
        GestureManager.shared.addPanGesture(to: controllerView, target: self, action: #selector(handlePan(_:)))
        GestureManager.shared.addPinchGesture(to: controllerView, target: self, action: #selector(handlePinch(_:)))
        GestureManager.shared.addRotateGesture(to: controllerView, target: self, action: #selector(handleRotate(_:)))
    }
    
    func attachControllerToView() {
        guard let selectedView else { return }
        if selectedView.isLayered || (selectedView.superview as? DraggableUIView)?.isLayered == true  {
            return
        }
        
        self.controllerView.translatesAutoresizingMaskIntoConstraints = false
        if let superView = selectedView.superview {
            superView.addSubview(controllerView)
            NSLayoutConstraint.activate([
                self.controllerView.leadingAnchor.constraint(equalTo: selectedView.leadingAnchor, constant: -20),
                self.controllerView.trailingAnchor.constraint(equalTo: selectedView.trailingAnchor, constant: 20),
                self.controllerView.topAnchor.constraint(equalTo: selectedView.topAnchor, constant: -20),
                self.controllerView.bottomAnchor.constraint(equalTo: selectedView.bottomAnchor, constant: 20)
            ])
            controllerView.transform = selectedView.transform
        }
    }
    
    func undoRedoHappen() {
        guard let selectedView else { return }
        self.controllerView.transform = selectedView.transform
    }
    
    @objc func deleteView(_ gesture: UIPanGestureRecognizer) {
        guard let selectedView, selectedView.movable, selectedView.isUserInteractionEnabled else { return }
        self.delegate?.deleteViewBtnTapped(view: selectedView)
    }
    
    @objc func adjustLayer(_ gesture: UIPanGestureRecognizer) {
        guard let selectedView, selectedView.movable, selectedView.isUserInteractionEnabled else { return }
        guard let btnView = gesture.view else { return }
        self.delegate?.adjustLayerOptionSelected(adjustBtn: btnView)
    }
    
    @objc func handleResize(_ gesture: UIPanGestureRecognizer) {
        guard let selectedView, selectedView.movable, selectedView.isUserInteractionEnabled else { return }
        guard let cornerView = gesture.view else { return }
        let touchPoint = gesture.location(in: controllerView)
        switch gesture.state {
        case .began:
            let originalTransform = selectedView.transform
            selectedView.transform = .identity
            selectedView.initialFrame = selectedView.frame
            selectedView.transform = originalTransform
            selectedView.initialTouchPoint = touchPoint
            selectedView.initialCenter = selectedView.center
            selectedView.currentCornerIndex = cornerView.tag
            selectedView.initialCenter = selectedView.center
            selectedView.registerState(currentState: selectedView.captureCurrentState())
        case .changed:
            let originalTransform = selectedView.transform
            selectedView.transform = .identity
            let deltaX = touchPoint.x - selectedView.initialTouchPoint.x
            let deltaY = touchPoint.y - selectedView.initialTouchPoint.y
            var newFrame = selectedView.initialFrame
            
            switch EdgeController(rawValue: cornerView.tag) {
            case .free:
                let average = ((deltaX + deltaY) / 2)
                let aspectRatio = newFrame.width / newFrame.height
                let newWidth = newFrame.width + average
                let newHeight = newWidth / aspectRatio
                newFrame.size.width = newWidth
                newFrame.size.height = newHeight
            case .bottomOnly:
                newFrame.size.height += deltaY
            case .rightOnly:
                newFrame.size.width += deltaX
            default:
                break
            }
            UIView.performWithoutAnimation {
                guard newFrame.width > 16 && newFrame.height > 16 else { return }
                selectedView.frame = newFrame
                let rotationAngle = atan2(originalTransform.b, originalTransform.a)
                if rotationAngle != 0 {
                    selectedView.center = selectedView.initialCenter
                }
            }
            selectedView.transform = originalTransform
        case .ended, .cancelled:
            selectedView.currentCornerIndex = nil
            delegate?.checkUndoRedoAvailable()
        default:
            break
        }
    }
    
    @objc func handleRotation(_ gesture: UIPanGestureRecognizer) {
        guard let selectedView, selectedView.movable, selectedView.isUserInteractionEnabled else { return }
        let touchPoint = gesture.location(in: controllerView.superview)
        
        switch gesture.state {
        case .began:
            selectedView.initialFrame = selectedView.frame
            selectedView.initialTouchPoint = touchPoint
            selectedView.initialRotationAngle = atan2(touchPoint.y - selectedView.center.y, touchPoint.x - selectedView.center.x)
            selectedView.registerState(currentState: selectedView.captureCurrentState())
        case .changed:
            let currentAngle = atan2(touchPoint.y - selectedView.center.y, touchPoint.x - selectedView.center.x)
            let angleDifference = currentAngle - selectedView.initialRotationAngle
            selectedView.transform = selectedView.transform.rotated(by: angleDifference)
            self.controllerView.transform = selectedView.transform
            selectedView.initialRotationAngle = currentAngle
        case .ended:
            delegate?.checkUndoRedoAvailable()
        default:
            break
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let selectedView else { return }
        guard let view = gesture.view, selectedView.movable, selectedView.isUserInteractionEnabled else { return }
        let translation = gesture.translation(in: view.superview)
        
        switch gesture.state {
        case .began:
            self.controllerView.alpha = 0
            selectedView.initialCenter = view.center
            selectedView.registerState(currentState: selectedView.captureCurrentState())
        case .changed:
            selectedView.center = CGPoint(x: selectedView.initialCenter.x + translation.x, y: selectedView.initialCenter.y + translation.y)
//            checkAlignment(view: selectedView)
        case .ended, .cancelled:
            self.controllerView.alpha = 1
            _ = selectedView.center
            delegate?.checkUndoRedoAvailable()
        default:
            break
        }
    }
    
//    private func setupGuideLines(view: UIView) {
//        horizontalLine.backgroundColor = .red
//        horizontalLine.frame = CGRect(x: 0, y: view.center.y - 0.5, width: view.bounds.width, height: 1)
//        horizontalLine.isHidden = true
//        view.addSubview(horizontalLine)
//        
//        verticalLine.backgroundColor = .red
//        verticalLine.frame = CGRect(x: view.center.x - 0.5, y: 0, width: 1, height: view.bounds.height)
//        verticalLine.isHidden = true
//        view.addSubview(verticalLine)
//    }
//    
//    private func checkAlignment(view: UIView) {
//        guard let superview = view.superview else { return }
//        self.setupGuideLines(view: controllerView)
//
//        let superviewCenter = superview.center
//        let viewCenter = view.center
//        
//        // Define a tolerance for alignment
//        let tolerance: CGFloat = 10.0
//        
//        // Check horizontal alignment
//        if abs(viewCenter.y - superviewCenter.y) <= tolerance {
//            horizontalLine.isHidden = false
//        } else {
//            horizontalLine.isHidden = true
//        }
//        
//        // Check vertical alignment
//        if abs(viewCenter.x - superviewCenter.x) <= tolerance {
//            verticalLine.isHidden = false
//        } else {
//            verticalLine.isHidden = true
//        }
//    }
    
    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let selectedView else { return }
        guard let view = gesture.view, selectedView.movable, selectedView.isUserInteractionEnabled else { return }
        
        switch gesture.state {
        case .began:
            selectedView.initialScale = gesture.scale
            selectedView.initialTransform = view.transform
            selectedView.initialBounds = view.bounds
            selectedView.registerState(currentState: selectedView.captureCurrentState())
        case .changed:
            let scale = gesture.scale
            selectedView.transform = selectedView.initialTransform.scaledBy(x: scale, y: scale)
            self.controllerView.transform = selectedView.transform
        case .ended:
            delegate?.checkUndoRedoAvailable()
            break
        default:
            break
        }
    }
    
    @objc private func handleRotate(_ gesture: UIRotationGestureRecognizer) {
        guard let selectedView else { return }
        guard let view = gesture.view, selectedView.movable, selectedView.isUserInteractionEnabled else { return }
        
        switch gesture.state {
        case .began:
            selectedView.initialRotation = gesture.rotation
            selectedView.initialTransform = view.transform
            selectedView.registerState(currentState: selectedView.captureCurrentState())
        case .changed:
            let rotation = gesture.rotation
            selectedView.transform = selectedView.initialTransform.rotated(by: rotation)
            self.controllerView.transform = selectedView.transform
        case .ended:
            _ = selectedView.transform
            delegate?.checkUndoRedoAvailable()
        default:
            break
        }
    }
}
