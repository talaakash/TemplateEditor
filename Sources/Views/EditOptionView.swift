import UIKit

class EditOptionView: UIView {
    @IBOutlet weak var editOptionCollection: UICollectionView!
    @IBOutlet private weak var closeBtn: UIControl!
    
    var editOptions: [EditType] = []
    var isRemoved: (() -> Void)?
    var selectedOption: ((EditType) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doInitSetup()
    }
    
    private func doInitSetup() {
        self.editOptionCollection.registerNib(for: OptionCell.self)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if superview != nil {
            DispatchQueue.main.async {
                if let flowLayout = self.editOptionCollection.collectionViewLayout as? UICollectionViewFlowLayout {
                    let inset = self.closeBtn.frame.origin.x + self.closeBtn.frame.width + 16
                    flowLayout.sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: 16)
                }
            }
        }
    }
}

// MARK: - Action Methods
extension EditOptionView {
    @IBAction private func cancelBtnTapped(_ sender: UIControl) {
        self.isRemoved?()
    }
}

// MARK: - CollectionView Delegate and Datasource
extension EditOptionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return editOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OptionCell.self), for: indexPath) as! OptionCell
        let currentOption = editOptions[indexPath.item]
        cell.optionImage.image = currentOption.getIcon
        cell.optionLabel.text = currentOption.name
        cell.isPremiumFeature = currentOption.isPremiumFeature
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedOption?(editOptions[indexPath.item])
    }
}
