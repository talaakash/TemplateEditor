import UIKit

class CanvasCell: UICollectionViewCell {

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var mainViewWidthAnchor: NSLayoutConstraint!
    @IBOutlet weak var mainViewHeightAnchor: NSLayoutConstraint!
    @IBOutlet weak var contentScrollView: UIScrollView!
    
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            if isSelected {
//                self.mainView.layer.borderWidth = 1
//                self.mainView.layer.borderColor = UIColor.black.cgColor
            } else {
//                self.mainView.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doInitSetup()
    }
    
    private func doInitSetup() {
        self.mainView.clipsToBounds = true
        self.contentScrollView.delegate = self
        if makeEditorScreenSecure {
            SecureView().makeSecure(to: self.contentScrollView)
        }
    }

}

extension CanvasCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return mainView
    }
}
