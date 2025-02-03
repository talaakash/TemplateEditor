import UIKit

class OptionCell: UICollectionViewCell {

    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var optionImage: UIImageView!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var premiumIconImg: UIImageView!
    @IBOutlet private weak var separatorViewSpace: NSLayoutConstraint!
    
    var isPremiumFeature: Bool = false {
        didSet {
            if isPremiumFeature, !isUserIsPaid {
                self.premiumIconImg.isHidden = false
            } else {
                self.premiumIconImg.isHidden = true
            }
        }
    }
    
    var isSeparatorVisible: Bool = false {
        didSet {
            if isSeparatorVisible {
                self.separatorView.isHidden = false
                self.separatorViewSpace.constant = 10
            } else {
                self.separatorView.isHidden = true
                self.separatorViewSpace.constant = 0
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
