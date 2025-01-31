import UIKit

class LockOptionView: UIView {
    
    @IBOutlet private weak var lockOptionCollection: UICollectionView!
    @IBOutlet private weak var selectedOptionLbl: UILabel!
    @IBOutlet private weak var selectedOptionSwitch: UISwitch!
    @IBOutlet private weak var viewBottomAnchor: NSLayoutConstraint!
    @IBOutlet private weak var lockOptionCollectionHeightAnchor: NSLayoutConstraint!
    
    private var lockOptions: [LockOptions] = LockOptions.allCases
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
    private var selectedOption: LockOptions = .interaction {
        didSet {
            self.setDataOfOption()
        }
    }

    var componentType: ComponentType? {
        didSet {
            self.editOptions()
        }
    }
    var selectedView: DraggableUIView?
    var actionHappen: ((ActionType) -> Void)?
    var changedOption: ((LockOptions, Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doInitSetup()
    }
    
    private func doInitSetup() {
        if isIpad {
            self.lockOptionCollectionHeightAnchor.constant *= 1.5
        }
        self.viewBottomAnchor.constant = self.viewBottomAnchor.constant + ScreenDetails.bottomSafeArea
        
        self.lockOptionCollection.registerNib(for: OptionCell.self)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            self.selectedIndexPath = IndexPath(item: 0, section: 0)
        }
    }
}

// MARK: - Private Methods
extension LockOptionView {
    private func setSelectedCell(of indexPath: IndexPath) {
        selectedOption = lockOptions[indexPath.item]
        let cell = self.lockOptionCollection.cellForItem(at: indexPath) as? OptionCell
        cell?.optionImage.image = cell?.optionImage.image
        cell?.optionImage.tintColor = UIColor.fontColorC29800
        cell?.optionLabel.textColor = UIColor.fontColorC29800
    }
    
    private func setDeselectCell(of indexPath: IndexPath) {
        let cell = self.lockOptionCollection.cellForItem(at: indexPath) as? OptionCell
        cell?.optionImage.image = cell?.optionImage.image
        cell?.optionImage.tintColor = .black
        cell?.optionLabel.textColor = UIColor.fontColor353535
    }
    
    private func setDataOfOption() {
        self.selectedOptionLbl.text = selectedOption.name
        switch selectedOption {
        case .interaction:
            self.selectedOptionSwitch.isOn = selectedView?.isUserInteractionEnabled ?? true
        case .change:
            self.selectedOptionSwitch.isOn = selectedView?.isEditable ?? true
        case .movement:
            self.selectedOptionSwitch.isOn = selectedView?.movable ?? true
        }
    }
    
    private func editOptions() {
        if componentType == .menuBox {
            self.lockOptions.removeAll(where: { $0 == .change })
        }
    }
}

// MARK: - Action Methods
extension LockOptionView {
    @IBAction private func cancelBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.close)
    }
    
    @IBAction private func checkBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.check)
    }
    
    @IBAction private func optionSwitchChanged(_ switch: UISwitch) {
        self.changedOption?(selectedOption, self.selectedOptionSwitch.isOn)
    }
}

// MARK: - CollectionView Delegate
extension LockOptionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lockOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OptionCell.self), for: indexPath) as! OptionCell
        let lockOption = lockOptions[indexPath.item]
        cell.optionLabel.text = lockOption.name
        cell.optionImage.image = UIImage(named: lockOption.iconName)
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
