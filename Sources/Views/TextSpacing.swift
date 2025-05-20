//
//  TextSpacing.swift
//  Pods
//
//  Created by Admin on 19/05/25.
//

import UIKit

class TextSpacing: UIView {
    
    @IBOutlet private weak var lineSpaceBtn: UIControl!
    @IBOutlet private weak var letterSpaceBtn: UIControl!
    @IBOutlet private weak var spacingSlider: UISlider!
    
    var actionHappen: ((ActionType) -> Void)?
    var valueChanged: ((TextSpace, CGFloat) -> Void)?
    var letterSpace: CGFloat = 0 {
        didSet {
            self.spacingSlider.value = Float(letterSpace)
        }
    }
    var lineSpace: CGFloat = 0
    private var selectedOption: TextSpace = .letter {
        didSet {
            self.setSelectedOption()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        doInitSetup()
    }
    
    private func doInitSetup() {
        self.selectedOption = .letter
    }
}

// MARK: Private Methods
extension TextSpacing {
    private func setSelectedOption() {
        if self.selectedOption == .letter {
            self.letterSpaceBtn.layer.borderColor = UIColor.black.cgColor
            self.lineSpaceBtn.layer.borderColor = Theme.secondaryBorderColor?.cgColor
            self.spacingSlider.value = Float(letterSpace)
        } else {
            self.lineSpaceBtn.layer.borderColor = UIColor.black.cgColor
            self.letterSpaceBtn.layer.borderColor = Theme.secondaryBorderColor?.cgColor
            self.spacingSlider.value = Float(lineSpace)
        }
    }
}

// MARK: Action Methods
extension TextSpacing {
    @IBAction private func closeBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.close)
    }
    
    @IBAction private func checkBtnTapped(_ sender: UIControl) {
        self.actionHappen?(.check)
    }
    
    @IBAction private func lineSpaceBtnTapped(_ sender: UIControl) {
        self.selectedOption = .line
    }
    
    @IBAction private func letterSpaceBtnTapped(_ sender: UIControl) {
        self.selectedOption = .letter
    }
    
    @IBAction private func spaceSliderChanged(_ sender: UISlider) {
        self.valueChanged?(self.selectedOption, CGFloat(sender.value))
        if self.selectedOption == .letter {
            self.letterSpace = CGFloat(sender.value)
        } else {
            self.lineSpace = CGFloat(sender.value)
        }
    }
}
