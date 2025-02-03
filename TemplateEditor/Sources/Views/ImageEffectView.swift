import UIKit

class ImageEffectView: UIView {
    @IBOutlet private weak var adjustSlider: UISlider!
    @IBOutlet private weak var effectTitleLbl: UILabel!
    @IBOutlet private weak var currentValueLbl: UILabel!
    
    var actionHappen: ((ActionType) -> Void)?
    var effectType: EffectType? {
        didSet {
            self.effectTitleLbl.text = effectType?.effectName
        }
    }
    var currentAdjustValue: CGFloat? {
        didSet {
            self.currentValueLbl.text = "\(Int(currentAdjustValue ?? 0))"
            self.adjustSlider.value = Float(currentAdjustValue ?? 0)
        }
    }
    var intensityChanged: ((CGFloat) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doInitSetup()
    }
    
    private func doInitSetup() {
        self.currentValueLbl.text = "\(currentAdjustValue ?? 0)"
        self.adjustSlider.value = Float(currentAdjustValue ?? 0)
        self.effectTitleLbl.text = effectType?.effectName
    }
    
}

// MARK: - Action methods
extension ImageEffectView {
    @IBAction private func closeBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.close)
    }
    
    @IBAction private func checkBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.check)
    }
    
    @IBAction private func sliderValueChanged(_ sender: UISlider) {
        self.currentValueLbl.text = "\(Int(sender.value))"
        self.intensityChanged?(CGFloat(sender.value * 0.01))
    }
}
