import UIKit

class MenuFontSizeView: UIView {
    
    @IBOutlet private weak var resizeOptionCollection: UICollectionView!
    @IBOutlet private weak var fontSizeSlider: UISlider!
    @IBOutlet private weak var currentSizeLbl: UILabel!
    @IBOutlet private weak var resizeOptionCollectionHeightAnchor: NSLayoutConstraint!
    
    private var availableOptions: [GenericModel<ResizeOption>] = EditController.resizeOptions
    private var currentOption: ResizeOption? {
        didSet {
            if let oldValue {
                self.sliderValues[oldValue] = fontSizeSlider.value
            }
            if let currentOption {
                self.fontSizeSlider.value = self.sliderValues[currentOption] ?? 0
                self.currentSizeLbl.text = String(Int(self.fontSizeSlider.value))
            }
        }
    }
    private var selectedIndexPath: IndexPath? {
        didSet {
            if let selectedIndexPath {
                self.setSelectedCell(of: selectedIndexPath)
            } else { return }
            if let oldValue {
                self.setDeselectCell(of: oldValue)
            }
        }
    }
    
    var sliderValues: [ResizeOption: Float] = [:]
    var actionHappen: ((ActionType) -> Void)?
    var adjustmentChanged: ((ResizeOption, CGFloat) -> Void)?
    var forStyle: MenuStyle? {
        didSet {
            switch forStyle {
            case .type2, .type9, .type10:
                self.availableOptions.removeAll(where: { $0.type == .itemDescription })
            default:
                break
            }
        }
    }
    
    var presentFontPicker: ((ResizeOption) -> Void)?
    var presentFontColorPicker: ((ResizeOption) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doInitSetup()
    }
    
    private func doInitSetup() {
        if isIpad {
            self.resizeOptionCollectionHeightAnchor.constant *= 1.5
        }
        
        self.resizeOptionCollection.registerNib(for: OptionCell.self)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            self.selectedIndexPath = IndexPath(item: 0, section: 0)
        }
    }
}

// MARK: - Private methods
extension MenuFontSizeView {
    private func setSelectedCell(of indexPath: IndexPath) {
        currentOption = availableOptions[indexPath.item].type
        let cell = self.resizeOptionCollection.cellForItem(at: indexPath) as? OptionCell
        cell?.optionImage.tintColor = Theme.primaryButtonColor
        cell?.optionLabel.textColor = Theme.secondaryTextColor
    }
    
    private func setDeselectCell(of indexPath: IndexPath) {
        let cell = self.resizeOptionCollection.cellForItem(at: indexPath) as? OptionCell
        cell?.optionImage.tintColor = .black
        cell?.optionLabel.textColor = Theme.primaryTextColor
    }
}

// MARK: - Action Methods
extension MenuFontSizeView {
    @IBAction private func closeBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.close)
    }
    
    @IBAction private func checkBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.check)
    }
    
    @IBAction private func fontSliderValueChanged(_ sender: UISlider) {
        if let currentOption {
            self.currentSizeLbl.text = String(Int(sender.value))
            adjustmentChanged?(currentOption, CGFloat(sender.value))
        }
    }
    
    @IBAction private func fontStyleBtnTapped(_ sender: UIControl) {
        if let currentOption {
            self.presentFontPicker?(currentOption)
        }
    }
    
    @IBAction private func fontColorBtnTapped(_ sender: UIControl) {
        if let currentOption {
            self.presentFontColorPicker?(currentOption)
        }
    }
}

// MARK: - CollectionView Delegate
extension MenuFontSizeView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OptionCell.self), for: indexPath) as! OptionCell
        let option = self.availableOptions[indexPath.item]
        if let iconName = option.icon {
            cell.optionImage.image = UIImage(named: iconName)
        } else {
            cell.optionImage.image = option.type.icon
        }
        cell.optionLabel.text = option.name ?? option.type.name
        
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
