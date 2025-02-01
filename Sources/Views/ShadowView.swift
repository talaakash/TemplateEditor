import UIKit

class ShadowView: UIView {
    
    @IBOutlet private weak var shadowOptionCollection: UICollectionView!
    @IBOutlet private weak var adjustSlider: UISlider!
    @IBOutlet private weak var shadowOptionCollectionHeightAnchor: NSLayoutConstraint!
    
    private var shadowOption: [ShadowOption] = ShadowOption.allCases
    private var selectedOption: ShadowOption = .opacity {
        didSet {
            self.setSelectShadowOption(oldValue)
        }
    }
    private var selectedIndexPath: IndexPath? {
        didSet {
            if let oldValue {
                self.setDeselectCell(of: oldValue)
            }
            if let selectedIndexPath {
                self.setSelectedCell(of: selectedIndexPath)
            }
        }
    }
    
    var actionHappen: ((ActionType) -> Void)?
    var selectedShadow: ((Float, CGFloat, CGSize) -> Void)?
    var currentShadow: (Float, CGFloat, CGSize)? {
        didSet {
            if let shadow = currentShadow { let (opacity, _, _) = shadow
                if selectedOption == .opacity {
                    self.adjustSlider.value = opacity
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doInitSetup()
    }
    
    private func doInitSetup() {
        if isIpad {
            self.shadowOptionCollectionHeightAnchor.constant *= 1.5
        }
        
        self.shadowOptionCollection.registerNib(for: OptionCell.self)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            self.selectedIndexPath = IndexPath(item: 0, section: 0)
        }
    }
}

// MARK: - Private Methods
extension ShadowView {
    private func setSelectedCell(of indexPath: IndexPath) {
        selectedOption = shadowOption[indexPath.item]
        let cell = self.shadowOptionCollection.cellForItem(at: indexPath) as? OptionCell
        cell?.optionImage.image = cell?.optionImage.image
        cell?.optionImage.tintColor = UIColor.fontColorC29800
        cell?.optionLabel.textColor = UIColor.fontColorC29800
    }
    
    private func setDeselectCell(of indexPath: IndexPath) {
        let cell = self.shadowOptionCollection.cellForItem(at: indexPath) as? OptionCell
        cell?.optionImage.image = cell?.optionImage.image
        cell?.optionImage.tintColor = .black
        cell?.optionLabel.textColor = UIColor.fontColor353535
    }
    
    private func setSelectShadowOption(_ option: ShadowOption) {
        if let shadow = currentShadow { let (opacity, radius, offset) = shadow
            switch option {
            case .opacity:
                self.currentShadow = (adjustSlider.value, radius, offset)
            case .radius:
                self.currentShadow = (opacity, CGFloat(adjustSlider.value), offset)
            case .width:
                self.currentShadow = (opacity, radius, CGSize(width: CGFloat(adjustSlider.value), height: offset.height))
            case .height:
                self.currentShadow = (opacity, radius, CGSize(width: offset.width, height: CGFloat(adjustSlider.value)))
            }
        
            switch selectedOption {
            case .opacity:
                self.adjustSlider.maximumValue = 1
                self.adjustSlider.value = opacity
            case .radius:
                self.adjustSlider.maximumValue = 7
                self.adjustSlider.value = Float(radius)
            case .width:
                self.adjustSlider.maximumValue = 7
                self.adjustSlider.value = Float(offset.width)
            case .height:
                self.adjustSlider.maximumValue = 7
                self.adjustSlider.value = Float(offset.height)
            }
        }
    }
}

// MARK: - Action Methods
extension ShadowView {
    @IBAction private func cancelBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.close)
    }
    
    @IBAction private func checkBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.check)
    }
    
    @IBAction private func sliderValueChanged(_ slider: UISlider) {
        if let shadow = currentShadow { let (opacity, radius, offset) = shadow
            switch selectedOption {
            case .opacity:
                self.selectedShadow?(slider.value, radius, offset)
            case .radius:
                self.selectedShadow?(opacity, CGFloat(slider.value), offset)
            case .width:
                self.selectedShadow?(opacity, radius, CGSize(width: CGFloat(slider.value), height: offset.height))
            case .height:
                self.selectedShadow?(opacity, radius, CGSize(width: offset.width, height: CGFloat(slider.value)))
            }
        }
    }
}

// MARK: - CollectionView Delegate
extension ShadowView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shadowOption.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OptionCell.self), for: indexPath) as! OptionCell
        let option = shadowOption[indexPath.item]
        cell.optionImage.image = option.iconName
        cell.optionLabel.text = option.name
        
        DispatchQueue.main.async {
            if indexPath == self.selectedIndexPath {
                self.setSelectedCell(of: indexPath)
            } else {
                self.setDeselectCell(of: indexPath)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndexPath = indexPath
    }
}
