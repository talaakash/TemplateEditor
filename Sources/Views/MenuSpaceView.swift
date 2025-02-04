import UIKit

class MenuSpaceView: UIView {
    
    @IBOutlet private weak var spaceOptionCollection: UICollectionView!
    @IBOutlet private weak var spaceAdjustSlider: UISlider!
    @IBOutlet private weak var spaceCollectionHeightAnchor: NSLayoutConstraint!
    
    private let spaceOptions: [GenericModel<Spacing>] = EditController.menuSpacing
    private var selectedOption: Spacing = .valueSpace
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
    
    var valueWidth: CGFloat?
    var valueSpace: CGFloat?
    
    var actionHappen: ((ActionType) -> Void)?
    var spaceChanged: ((Spacing, CGFloat) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doInitSetup()
    }
    
    private func doInitSetup() {
        if isIpad {
            self.spaceCollectionHeightAnchor.constant *= 1.5
        }
        self.spaceOptionCollection.registerNib(for: OptionCell.self)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            self.selectedIndexPath = IndexPath(item: 0, section: 0)
        }
    }
}

// MARK: - Private Methods
extension MenuSpaceView {
    private func setSelectedCell(of indexPath: IndexPath) {
        selectedOption = spaceOptions[indexPath.item].type
        let cell = self.spaceOptionCollection.cellForItem(at: indexPath) as? OptionCell
        cell?.optionImage.image = cell?.optionImage.image
        cell?.optionImage.tintColor = Theme.primaryButtonColor
        cell?.optionLabel.textColor = Theme.secondaryTextColor
        switch selectedOption {
        case .valueSpace:
            self.spaceAdjustSlider.value = Float(self.valueSpace ?? 0)
        case .valueWidth:
            self.spaceAdjustSlider.value = Float(self.valueWidth ?? 0)
        }
    }
    
    private func setDeselectCell(of indexPath: IndexPath) {
        let cell = self.spaceOptionCollection.cellForItem(at: indexPath) as? OptionCell
        cell?.optionImage.image = cell?.optionImage.image
        cell?.optionImage.tintColor = .black
        cell?.optionLabel.textColor = Theme.primaryTextColor
        switch selectedOption {
        case .valueSpace:
            self.valueSpace = CGFloat(self.spaceAdjustSlider.value)
        case .valueWidth:
            self.valueWidth = CGFloat(self.spaceAdjustSlider.value)
        }
    }
}

// MARK: - Action Methods
extension MenuSpaceView {
    @IBAction private func closeBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.close)
    }
    
    @IBAction private func checkBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.check)
    }
    
    @IBAction private func spaceSliderValueChanged(_ sender: UISlider) {
        self.spaceChanged?(selectedOption, CGFloat(sender.value))
    }
}

extension MenuSpaceView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spaceOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OptionCell.self), for: indexPath) as! OptionCell
        let option = self.spaceOptions[indexPath.item]
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
