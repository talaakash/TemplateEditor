import Foundation
import UIKit

class AlertView: UIView {
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var alertMessage: UILabel!
    @IBOutlet weak var alertBtnView: UIStackView!
    @IBOutlet weak var btnViewHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if isIpad {
            btnViewHeight.constant = btnViewHeight.constant * 1.5
        }
    }
}
