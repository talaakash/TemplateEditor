import UIKit

class ChoseImageView: UIView {
    
    @IBOutlet private weak var chooseOptionCollection: UICollectionView!
    @IBOutlet private weak var viewBottomAnchor: NSLayoutConstraint!
    @IBOutlet private weak var imgOptionCollectionHeightAnchor: NSLayoutConstraint!
    
    private let availableOption: [FilePickType] = FilePickType.allCases
    
    var actionHappen: ((ActionType) -> Void)?
    var selectedOption: ((FilePickType) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doInitSetup()
    }
    
    private func doInitSetup() {
        if isIpad {
            self.imgOptionCollectionHeightAnchor.constant *= 1.5
        }
        self.viewBottomAnchor.constant = self.viewBottomAnchor.constant + ScreenDetails.bottomSafeArea
        
        self.chooseOptionCollection.registerNib(for: OptionCell.self)
    }
}

// MARK: - Action Methods
extension ChoseImageView {
    @IBAction private func closeBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.close)
    }
    
    @IBAction private func checkBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.check)
    }
}

// MARK: - CollectionView Delegate
extension ChoseImageView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableOption.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OptionCell.self), for: indexPath) as! OptionCell
        cell.optionImage.image = UIImage(named: availableOption[indexPath.item].iconName)
        cell.optionLabel.text = availableOption[indexPath.item].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedOption?(availableOption[indexPath.item])
        self.actionHappen?(.close)
    }
}
