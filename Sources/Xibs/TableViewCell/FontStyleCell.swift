import UIKit

class FontStyleCell: UITableViewCell {

    @IBOutlet weak var styleName: UILabel!
    @IBOutlet private weak var subTypeImg: UIImageView!
    
    var hasFaces: Bool = false {
        didSet {
            if hasFaces {
                self.subTypeImg.isHidden = false
            } else {
                self.subTypeImg.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
