//
//  Untitled.swift
//  Pods
//
//  Created by Akash Tala on 16/05/25.
//

import UIKit

class BackgroundOptions: UIView {
    struct BGOption {
        let image: UIImage?
        let bgColor: String?
    }
    
    @IBOutlet private weak var backgroundOptionCollection: UICollectionView!
    @IBOutlet private weak var imageBtn: UIControl!
    @IBOutlet private weak var colorBtn: UIControl!
    @IBOutlet private weak var backgroundCollectionHeight: NSLayoutConstraint!
    
    private var selectedOptionIndex: Int = 0 { // 0 means bgImage and 1 means bgColor
        didSet {
            self.setNewDataInCollection()
        }
    }
    private var options: [BGOption] = []
    var actionHappen: ((ActionType) -> Void)?
    var selectedBackgroundColor: ((String) -> Void)?
    var selectedBackgroundImage: ((UIImage) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doInitSetup()
    }
    
    private func doInitSetup() {
        if isIpad {
            self.backgroundCollectionHeight.constant *= 1.5
        }
        self.backgroundOptionCollection.registerNib(for: OptionCell.self)
        self.selectedOptionIndex = 0
    }
}

// MARK: Private Methods
extension BackgroundOptions {
    private func setNewDataInCollection() {
        let colorHexCodes: [String] = [
            "#808080","#FFA500","#D3D3D3","#A9A9A9","#000080","#008080","#808000","#800000","#800080","#00FF00","#00FFFF","#C0C0C0","#FF7F50","#4B0082","#FFD700","#FA8072","#F44336","#E91E63","#9C27B0","#3F51B5","#2196F3", "#03A9F4", "#00BCD4", "#009688", "#4CAF50", "#8BC34A", "#CDDC39", "#FFEB3B", "#FFC107", "#FF9800", "#FF5722", "#795548", "#9E9E9E", "#607D8B", "#FF0000", "#00FF00", "#0000FF", "#FFFF00","#00FFFF","#FF00FF","#000000"
        ]
        let shapes = ["star", "curvedCircle", "circleFilled", "circle", "capsule", "heartFilled", "heart", "line", "lineBreaked", "rectangleCircle", "rectangleFilled", "rectangle", "square", "arrowFilled", "arrow", "arrowThinFilled", "arrowThin"]
        self.imageBtn.borderColor = UIColor(named: "borderColor353535", in: packageBundle, compatibleWith: nil)
        self.colorBtn.borderColor = UIColor(named: "borderColor353535", in: packageBundle, compatibleWith: nil)
        if self.selectedOptionIndex == 0 {
            self.options = shapes.map({ BGOption(image: UIImage(named: $0, in: packageBundle, compatibleWith: nil), bgColor: nil) })
            self.imageBtn.borderColor = UIColor.black
        } else {
            self.options = colorHexCodes.map({ BGOption(image: nil, bgColor: $0) })
            self.colorBtn.borderColor = UIColor.black
        }
        self.backgroundOptionCollection.reloadData()
    }
}

// MARK: Action Methods
extension BackgroundOptions {
    @IBAction private func closeBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.close)
    }
    
    @IBAction private func checkBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.check)
    }
    
    @IBAction private func bgImageOptionSelected(_ sender: UIControl) {
        self.selectedOptionIndex = 0
    }
    
    @IBAction private func bgColorOptionSelected(_ sender: UIControl) {
        self.selectedOptionIndex = 1
    }
}

// MARK: CollectionView DataSource
extension BackgroundOptions: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OptionCell.self), for: indexPath) as! OptionCell
        let option = self.options[indexPath.item]
        cell.optionLabel.text = ""
        if let image = option.image {
            cell.optionImage.image = image
            cell.optionImage.backgroundColor = .clear
        } else {
            cell.optionImage.image = nil
            cell.optionImage.backgroundColor = UIColor(hex: option.bgColor ?? "")
            cell.optionImage.layer.cornerRadius = 8
        }
        cell.optionImage.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let option = self.options[indexPath.item]
        if let image = option.image {
            self.selectedBackgroundImage?(image)
        } else if let color = option.bgColor {
            self.selectedBackgroundColor?(color)
        }
    }
}
