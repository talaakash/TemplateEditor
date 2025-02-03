//
//  ImageQualityInputController.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

import UIKit

class ImageQualityInputController: UIViewController {

    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var hdBtn: UIControl!
    @IBOutlet private weak var sdBtn: UIControl!
    @IBOutlet private weak var hdBtnImage: UIImageView!
    @IBOutlet private weak var sdBtnImage: UIImageView!
    @IBOutlet private weak var mainViewLeadingAnchor: NSLayoutConstraint!
    @IBOutlet private weak var mainViewTrailingAnchor: NSLayoutConstraint!
    
    private var currentQuality: ImageResolution = .HD {
        didSet {
            UIView.animate(withDuration: 0.2, animations: {
                self.changeQualitySelection()
            })
        }
    }
    
    var selectedQuality: ((ImageResolution) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isIpad {
            self.mainViewLeadingAnchor.constant = self.view.frame.width / 4
            self.mainViewTrailingAnchor.constant = self.view.frame.width / 4
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.mainView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        self.view.alpha = 0
        UIView.animate(withDuration: 0.33, animations: {
            self.view.alpha = 1
            self.mainView.transform = .identity
        })
    }
}

// MARK: - Private Methods
extension ImageQualityInputController {
    private func select(btn button: UIControl) {
        button.layer.borderColor = UIColor.borderColorF5C000?.cgColor
        button.backgroundColor = UIColor.buttonBgF5C000?.withAlphaComponent(button.backgroundColorAlpha)
    }
    
    private func deSelect(btn button: UIControl) {
        button.layer.borderColor = UIColor.borderColor353535?.cgColor
        button.backgroundColor = UIColor.buttonBg353535?.withAlphaComponent(button.backgroundColorAlpha)
    }
    
    private func changeQualitySelection() {
        switch self.currentQuality {
        case .SD:
            self.select(btn: sdBtn)
            self.deSelect(btn: hdBtn)
            self.sdBtnImage.image = UIImage(named: "radioChecked", in: packageBundle, with: nil)
            self.hdBtnImage.image = UIImage(named: "radioUnChecked", in: packageBundle, with: nil)
        case .HD:
            self.select(btn: hdBtn)
            self.deSelect(btn: sdBtn)
            self.sdBtnImage.image = UIImage(named: "radioUnChecked", in: packageBundle, with: nil)
            self.hdBtnImage.image = UIImage(named: "radioChecked", in: packageBundle, with: nil)
        }
    }
}

// MARK: - Action Methods
extension ImageQualityInputController {
    @IBAction private func hdBtnTapped(_ sender: UIControl) {
        self.currentQuality = .HD
    }
    
    @IBAction private func sdBtnTapped(_ sender: UIControl) {
        self.currentQuality = .SD
    }
    
    @IBAction private func continueBtnTapped(_ sender: UIControl) {
        UIView.animate(withDuration: 0.33, animations: {
            self.view.alpha = 0
            self.mainView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            self.selectedQuality?(self.currentQuality)
            self.dismiss(animated: false)
        })
    }
    
    @IBAction private func cancelBtnTapped(_ sender: UIControl) {
        UIView.animate(withDuration: 0.33, animations: {
            self.view.alpha = 0
            self.mainView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            self.dismiss(animated: false)
        })
    }
}
