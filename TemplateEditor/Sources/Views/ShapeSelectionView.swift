import UIKit

class ShapeSelectionView: UIView {
    
    @IBOutlet private weak var shapeCollection: UICollectionView!
    @IBOutlet private weak var shapeCollectionHeightAnchor: NSLayoutConstraint!
    
    private let availableShapes: [String] = ["star", "curvedCircle", "circleFilled", "circle", "capsule", "heartFilled", "heart", "line", "lineBreaked", "rectangleCircle", "rectangleFilled", "rectangle", "square", "arrowFilled", "arrow", "arrowThinFilled", "arrowThin"]
    
    var actionHappen: ((ActionType) -> Void)?
    var selectedShape: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doInitSetup()
    }
    
    private func doInitSetup() {
        if isIpad {
            self.shapeCollectionHeightAnchor.constant *= 1.5
        }
        self.shapeCollection.registerNib(for: OptionCell.self)
    }
}

// MARK: - Action Methods
extension ShapeSelectionView {
    @IBAction private func closeBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.close)
    }
    
    @IBAction private func checkBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.check)
    }
}

// MARK: - CollectionView Delegate
extension ShapeSelectionView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableShapes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OptionCell.self), for: indexPath) as! OptionCell
        cell.optionImage.image = UIImage(named: availableShapes[indexPath.item], in: packageBundle, with: .none)
        cell.optionLabel.text = availableShapes[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedShape?(availableShapes[indexPath.item])
    }
}
