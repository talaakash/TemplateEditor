import UIKit

class AdjustmentView: UIView {
    
    @IBOutlet private weak var filterCollection: UICollectionView!
    @IBOutlet private weak var adjustmentSlider: UISlider!
    @IBOutlet private weak var viewBottomAnchor: NSLayoutConstraint!
    @IBOutlet private weak var filterCollectionHeightAnchor: NSLayoutConstraint!
    
    private let availableFilters: [ImageFilters] = ImageFilters.allCases
    private var sliderValues: [ImageFilters: Float] = [:]
    private var selectedFilter: ImageFilters? {
        didSet {
            if let oldValue {
                sliderValues[oldValue] = adjustmentSlider.value
            }
            if let selectedFilter {
                adjustmentSlider.value = sliderValues[selectedFilter] ?? 0
            }
        }
    }
    private var processImg: CIImage?
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
    
    var actionHappen: ((ActionType) -> Void)?
    var outputImg: ((CIImage) -> Void)?
    var originalImg: CIImage?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doInitSetup()
    }
    
    private func doInitSetup() {
        if isIpad {
            self.filterCollectionHeightAnchor.constant *= 1.5
        }
        self.viewBottomAnchor.constant = self.viewBottomAnchor.constant + ScreenDetails.bottomSafeArea
        self.filterCollection.registerNib(for: OptionCell.self)
        
        for filter in availableFilters {
            self.sliderValues[filter] = 0
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            self.selectedIndexPath = IndexPath(item: 0, section: 0)
        }
    }
}

// MARK: - Private Methods
extension AdjustmentView {
    private func setDefaultFilterValue() {
        guard let selectedFilter else { return }
        var usedFilters = sliderValues
        usedFilters = usedFilters.filter({ $0.value != 0 })
        usedFilters.removeValue(forKey: selectedFilter)
        processImg = originalImg
        for (filter, value) in usedFilters {
            switch filter {
            case .brightness:
                if let filteredImg = processImg!.applyBrightness(CGFloat(value)) {
                    processImg = filteredImg
                }
            case .contrast:
                if let filteredImg = processImg!.applyContrast(CGFloat(value)) {
                    processImg = filteredImg
                }
            case .saturation:
                if let filteredImg = processImg!.applySaturation(CGFloat(value)) {
                    processImg = filteredImg
                }
            case .exposure:
                if let filteredImg = processImg!.applyExposure(CGFloat(value)) {
                    processImg = filteredImg
                }
            case .vibrance:
                if let filteredImg = processImg!.applyVibrance(CGFloat(value)) {
                    processImg = filteredImg
                }
            case .warmth:
                if let filteredImg = processImg!.applyWarmth(CGFloat(value)) {
                    processImg = filteredImg
                }
            case .vignette:
                if let filteredImg = processImg!.applyVignette(CGFloat(value)) {
                    processImg = filteredImg
                }
            }
        }
    }
    
    private func setIntensityInCurrentFilter(_ intensity: Float) {
        if let selectedFilter, let processImg {
            switch selectedFilter {
            case .brightness:
                if let filteredImg = processImg.applyBrightness(CGFloat(intensity)) {
                    outputImg?(filteredImg)
                }
            case .contrast:
                if let filteredImg = processImg.applyContrast(CGFloat(intensity)) {
                    outputImg?(filteredImg)
                }
            case .saturation:
                if let filteredImg = processImg.applySaturation(CGFloat(intensity)) {
                    outputImg?(filteredImg)
                }
            case .exposure:
                if let filteredImg = processImg.applyExposure(CGFloat(intensity)) {
                    outputImg?(filteredImg)
                }
            case .vibrance:
                if let filteredImg = processImg.applyVibrance(CGFloat(intensity)) {
                    outputImg?(filteredImg)
                }
            case .warmth:
                if let filteredImg = processImg.applyWarmth(CGFloat(intensity)) {
                    outputImg?(filteredImg)
                }
            case .vignette:
                if let filteredImg = processImg.applyVignette(CGFloat(intensity)) {
                    outputImg?(filteredImg)
                }
            }
        }
    }
    
    private func setSelectedCell(of indexPath: IndexPath) {
        selectedFilter = availableFilters[indexPath.item]
        self.setDefaultFilterValue()
        let cell = self.filterCollection.cellForItem(at: indexPath) as? OptionCell
        cell?.optionImage.tintColor = UIColor.fontColorC29800
        cell?.optionLabel.textColor = UIColor.fontColorC29800
    }
    
    private func setDeselectCell(of indexPath: IndexPath) {
        let cell = self.filterCollection.cellForItem(at: indexPath) as? OptionCell
        cell?.optionImage.tintColor = UIColor.black
        cell?.optionLabel.textColor = UIColor.fontColor353535
    }
}

// MARK: - Action Methods
extension AdjustmentView {
    @IBAction private func closeBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.close)
    }
    
    @IBAction private func checkBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.check)
    }
    
    @IBAction private func adjustmentSliderValueChanged(_ sender: UISlider) {
        self.setIntensityInCurrentFilter(sender.value)
    }
}

// MARK: - CollectionView Delegate
extension AdjustmentView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableFilters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OptionCell.self), for: indexPath) as! OptionCell
        cell.optionImage.image = UIImage(named: availableFilters[indexPath.row].iconName)
        cell.optionLabel.text = availableFilters[indexPath.row].title
        
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
