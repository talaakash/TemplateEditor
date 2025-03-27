//
//  ContainerView.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

import UIKit

class ViewState {
    var center: CGPoint
    var transform: CGAffineTransform
    var bounds: CGRect
    
    init(center: CGPoint, transform: CGAffineTransform, bounds: CGRect) {
        self.center = center
        self.transform = transform
        self.bounds = bounds
    }
}

enum EdgeController: Int {
    case free = 0
    case bottomOnly = 1
    case rightOnly = 2
}

public class DraggableUIView: UIView {

    public var componentType: String?
    public var isBgImg: Bool = false
    var movable: Bool = true
    var isEnabled: Bool = true
    var isEditable: Bool = true
    var isRemovable: Bool = true
    var isDuplicatable: Bool = true
    var isLayered: Bool = false
    var isBlurredView: Bool?
    var blurIntensity: CGFloat = .zero
    
    var initialCenter: CGPoint = .zero
    var initialBounds: CGRect = .zero
    var initialTransform: CGAffineTransform = .identity
    var initialScale: CGFloat = 1.0
    var initialRotation: CGFloat = 0.0
    
    var initialFrame: CGRect = .zero
    var initialTouchPoint: CGPoint = .zero
    var currentCornerIndex: Int?
    var initialRotationAngle: CGFloat = .zero
    var originalImage: UIImage? {
        didSet {
            guard let imgView = self.subviews.compactMap({ $0 as? UIImageView }).first else { return }
            if self.blurIntensity > .zero {
                if self.componentType == ComponentType.shape.rawValue {
                    imgView.image = originalImage?.applyBlur(with: self.blurIntensity)?.withRenderingMode(.alwaysTemplate)
                } else {
                    imgView.image = originalImage?.applyBlur(with: self.blurIntensity)
                }
            } else {
                imgView.image = originalImage
            }
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if let txtView = self.subviews.compactMap({ $0 as? UITextView }).first {
            txtView.centerTextVertically()
        }
    }
    
    public override func addSubview(_ view: UIView) {
        super.addSubview(view)
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale
    }
    
    private func doInitSetup() {
        self.isUserInteractionEnabled = true
    }
    
    private func increaseFontSize() {
        guard let label = self.subviews.compactMap({ $0 as? UITextView }).first else { return }
        let scale = sqrt(self.transform.a * self.transform.a + self.transform.c * self.transform.c)
        let newFont = scale * label.font!.pointSize
        label.font = label.font?.withSize(newFont)
    }
    
    func captureCurrentState() -> ViewState {
        return ViewState(center: self.center, transform: self.transform, bounds: self.bounds)
    }
    
    func registerState(currentState: ViewState) {
        let previousState = captureCurrentState()
        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] _ in
            self?.registerState(currentState: previousState)
        })
        restoreState(currentState)
    }
    
    func restoreState(_ state: ViewState) {
        self.center = state.center
        self.transform = state.transform
        self.bounds = state.bounds
    }
    
}
