import UIKit

class MenuTypeCell: UICollectionViewCell {

    @IBOutlet weak var typeLbl: UILabel!
    @IBOutlet weak var typeBackground: UIView!
    
//    override var isSelected: Bool {
//        didSet {
//            if isSelected {
//                self.typeBackground.backgroundColor = .buttonBgF5C000.withAlphaComponent(0.1)
//                self.typeBackground.borderColor = .buttonBgF5C000
//            } else {
//                self.typeBackground.backgroundColor = .buttonBgF0F0F0
//                self.typeBackground.borderColor = .clear
//            }
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
