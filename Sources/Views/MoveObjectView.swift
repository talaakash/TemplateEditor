import UIKit

class MoveObjectView: UIView {
    
    @IBOutlet private weak var upArrowBtn: UIControl!
    @IBOutlet private weak var downArrowBtn: UIControl!
    @IBOutlet private weak var leftArrowBtn: UIControl!
    @IBOutlet private weak var rightArrowBtn: UIControl!
    
    var selectedOption: ((RearrangeOption) -> Void)?
    var actionHappen: ((ActionType) -> Void)?
    private var timer: Timer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doInitSetup()
    }
    
    private func doInitSetup() {
        
        self.upArrowBtn.tag = RearrangeOption.up.rawValue
        self.downArrowBtn.tag = RearrangeOption.down.rawValue
        self.leftArrowBtn.tag = RearrangeOption.left.rawValue
        self.rightArrowBtn.tag = RearrangeOption.right.rawValue
        GestureManager.shared.addLongPressGesture(to: upArrowBtn, target: self, action: #selector(handleLongPress))
        GestureManager.shared.addLongPressGesture(to: downArrowBtn, target: self, action: #selector(handleLongPress))
        GestureManager.shared.addLongPressGesture(to: leftArrowBtn, target: self, action: #selector(handleLongPress))
        GestureManager.shared.addLongPressGesture(to: rightArrowBtn, target: self, action: #selector(handleLongPress))
    }
    
}

// MARK: - Private methods
extension MoveObjectView {
    private func startContinuesCallBack(with option: RearrangeOption) {
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true, block: { _ in
            self.selectedOption?(option)
        })
    }
}

// MARK: - Action Methods
extension MoveObjectView {
    @IBAction private func cancelBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.close)
    }
    
    @IBAction private func checkBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.check)
    }
    
    @IBAction private func moveLeftBtnTapped(_ sender: UIControl) {
        self.selectedOption?(.left)
    }
    
    @IBAction private func moveRightBtnTapped(_ sender: UIControl) {
        self.selectedOption?(.right)
    }
    
    @IBAction private func moveUpBtnTapped(_ sender: UIControl) {
        self.selectedOption?(.up)
    }
    
    @IBAction private func moveDownBtnTapped(_ sender: UIControl) {
        self.selectedOption?(.down)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        guard let view = gesture.view, let option = RearrangeOption(rawValue: view.tag) else { return }
        if gesture.state == .began {
            self.startContinuesCallBack(with: option)
        }
        if gesture.state == .ended {
            self.timer?.invalidate()
        }
    }
}
