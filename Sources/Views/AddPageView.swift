import UIKit

class AddPageView: UIView {
    
    @IBOutlet private weak var pageTypeCollection: UICollectionView!
    @IBOutlet private weak var pageTypeCollectionHeightAnchor: NSLayoutConstraint!
    
    private var addPageData: [AddPageType] = AddPageType.allCases
    
    var selectedOption: ((AddPageType) -> Void)?
    var actionHappen: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doInitSetup()
    }
    
    private func doInitSetup() {
        if isIpad {
            self.pageTypeCollectionHeightAnchor.constant *= 1.5
        }
        
        self.pageTypeCollection.registerNib(for: OptionCell.self)
    }
    
}

// MARK: - Action Methods
extension AddPageView {
    @IBAction private func closeBtnTapped(_ sender: UIControl) {
        self.actionHappen?()
    }
    
    @IBAction private func checkBtnTapped(_ sender: UIControl) {
        self.actionHappen?()
    }
}

// MARK: - CollectionView Delegate
extension AddPageView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.addPageData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OptionCell.self), for: indexPath) as! OptionCell
        let option = self.addPageData[indexPath.item]
        cell.optionImage.image = option.iconName
        cell.optionLabel.text = option.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedOption?(self.addPageData[indexPath.item])
    }
}
