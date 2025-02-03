//
//  ExportOption.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

import UIKit

enum ExportOption {
    case qr, pdf, images
}

class ExportOptions: UIViewController {

    @IBOutlet private weak var qrCodeBtn: UIControl!
    @IBOutlet private weak var imagesBtn: UIControl!
    @IBOutlet private weak var pdfBtn: UIControl!
    
    private var selectedOption: ExportOption = .qr {
        didSet {
            self.changeSelection()
        }
    }
    var exportOption: ((ExportOption) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectedOption = .qr
    }
}

// MARK: - Private Methods
extension ExportOptions {
    private func changeSelection() {
        self.qrCodeBtn.layer.borderColor = UIColor.clear.cgColor
        self.imagesBtn.layer.borderColor = UIColor.clear.cgColor
        self.pdfBtn.layer.borderColor = UIColor.clear.cgColor
        switch selectedOption {
        case .qr:
            self.qrCodeBtn.layer.borderColor = UIColor(named: "borderColorF5C000")?.cgColor
        case .pdf:
            self.pdfBtn.layer.borderColor = UIColor(named: "borderColorF5C000")?.cgColor
        case .images:
            self.imagesBtn.layer.borderColor = UIColor(named: "borderColorF5C000")?.cgColor
        }
    }
}

// MARK: - Action Methods
extension ExportOptions {
    @IBAction private func qrCodeBtnTapped(_ sender: UIControl) {
        self.selectedOption = .qr
    }
    
    @IBAction private func imagesBtnTapped(_ sender: UIControl) {
        self.selectedOption = .images
    }
    
    @IBAction private func pdfBtnTapped(_ sender: UIControl) {
        self.selectedOption = .pdf
    }
    
    @IBAction private func exportBtnTapped(_ sender: UIControl) {
        self.exportOption?(self.selectedOption)
        self.dismiss(animated: false)
    }
    
    @IBAction private func closeBtnTapped(_ sender: UIControl) {
        self.dismiss(animated: false)
    }
}
