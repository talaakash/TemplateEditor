import UIKit

class ChoseImageView: UIView {
    
    @IBOutlet private weak var chooseOptionCollection: UICollectionView!
    @IBOutlet private weak var imgOptionCollectionHeightAnchor: NSLayoutConstraint!
    
    private let availableOption: [GenericModel] = EditController.filePickTypes
    
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
        let option = self.availableOption[indexPath.item]
        if let iconName = option.icon {
            cell.optionImage.image = UIImage(named: iconName)
        } else {
            cell.optionImage.image = option.type.iconName
        }
        cell.optionLabel.text = option.name ?? option.type.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedOption?(availableOption[indexPath.item].type)
        self.actionHappen?(.close)
    }
}
