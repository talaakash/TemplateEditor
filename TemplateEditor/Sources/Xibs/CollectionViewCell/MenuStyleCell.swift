import UIKit

class MenuStyleCell: UICollectionViewCell {

    @IBOutlet weak var styleImg: UIImageView!
    @IBOutlet private weak var premiumIcon: UIImageView!
    
    
    var isPremium: Bool = false {
        didSet {
            self.premiumIcon.isHidden = !isPremium
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
