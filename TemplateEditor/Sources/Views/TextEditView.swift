import UIKit

class TextEditView: UIView {
    
    @IBOutlet private weak var textEditorTxt: UITextField!
    
    var currentText: String? {
        didSet {
            self.textEditorTxt.text = currentText
        }
    }
    var actionHappen: ((ActionType) -> Void)?
    var changedText: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doInitSetup()
    }
    
    private func doInitSetup() {
        textEditorTxt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
}

// MARK: - Action Methods
extension TextEditView {
    @IBAction private func closeBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.close)
    }
    
    @IBAction private func checkBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.check)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        self.changedText?(text)
    }
}
