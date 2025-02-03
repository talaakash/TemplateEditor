import UIKit

class BlendModeView: UIView {
    @IBOutlet private weak var blendModeCollection: UICollectionView!
    @IBOutlet private weak var alphaSlider: UISlider!
    @IBOutlet private weak var modeCollectionHeightAnchor: NSLayoutConstraint!
    
    private let availableModes: [GenericModel<BlendMode>] = EditController.blendModeOptions
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
    private var selectedMode: BlendMode? = .normal
    
    var actionHappen: ((ActionType) -> Void)?
    var selectedBlendMode: ((BlendMode, CGFloat) -> Void)?
    
    var originalAlpha: CGFloat? {
        didSet {
            self.alphaSlider.value = Float(originalAlpha ?? 0)
        }
    }
    var originalMode: BlendMode? {
        didSet {
            self.selectedMode = originalMode
            if let originalMode, let indexOfMode = self.availableModes.firstIndex(where: { $0.type == originalMode }) {
                self.blendModeCollection.selectItem(at: IndexPath(item: indexOfMode, section: 0), animated: true, scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doInitSetup()
    }
    
    private func doInitSetup() {
        self.blendModeCollection.registerNib(for: BlendModeCell.self)
        self.alphaSlider.value = Float(self.originalAlpha ?? 0)
    }
}

//MARK: - Private Methods
extension BlendModeView {
    private func setSelectedCell(of indexPath: IndexPath) {
        let cell = self.blendModeCollection.cellForItem(at: indexPath) as? BlendModeCell
        cell?.modeImage.layer.borderColor = UIColor.fontColorC29800?.cgColor
        cell?.modeName.textColor = UIColor.fontColorC29800
        self.blendModeCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    private func setDeselectCell(of indexPath: IndexPath) {
        let cell = self.blendModeCollection.cellForItem(at: indexPath) as? BlendModeCell
        cell?.modeImage.layer.borderColor = UIColor.clear.cgColor
        cell?.modeName.textColor = UIColor.fontColor303030
    }
}

//MARK: - Action Method
extension BlendModeView {
    @IBAction private func closeBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.close)
    }
    
    @IBAction private func checkBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.check)
    }
    
    @IBAction private func alphaSliderValueChanged(_ sender: UISlider) {
        self.selectedBlendMode?(selectedMode ?? .normal, CGFloat(sender.value))
    }
}

// MARK: - CollectionView Delegate
extension BlendModeView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableModes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: BlendModeCell.self), for: indexPath) as! BlendModeCell
        let mode = self.availableModes[indexPath.item]
        if let iconName = mode.icon {
            cell.modeImage.image = UIImage(named: iconName)
        } else {
            cell.modeImage.image = mode.type.iconName
        }
        cell.modeName.text = mode.name ?? mode.type.name
        
        DispatchQueue.main.async {
            if self.availableModes[indexPath.item].type == self.selectedMode {
                self.setSelectedCell(of: indexPath)
            } else {
                self.setDeselectCell(of: indexPath)
            }
            
            if self.modeCollectionHeightAnchor.constant != cell.frame.height {
                self.modeCollectionHeightAnchor.constant = cell.frame.height
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedMode = availableModes[indexPath.item].type
        self.selectedIndexPath = indexPath
        self.selectedBlendMode?(self.selectedMode!, CGFloat(alphaSlider.value))
    }
}
