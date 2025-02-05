//
//  Type13Menu.swift
//  Pods
//
//  Created by Akash Tala on 05/02/25.
//


import UIKit

class Type13Menu: ItemView {
    @IBOutlet private weak var itemName: UILabel!
    @IBOutlet private weak var dottedLineImg: UIImageView!
    @IBOutlet private weak var itemDescription: UILabel!
    @IBOutlet private weak var itemValueContainer: UIStackView!
    
    var noOfColumns: Int = 0
    override var columnWidth: CGFloat {
        didSet {
            self.setNewColumnWidth()
        }
    }
    override var columnSpace: CGFloat {
        didSet {
            self.itemValueContainer.spacing = columnSpace
        }
    }
    override var data: MenuItemDetails? {
        didSet {
            self.addDataInContainer()
        }
    }
    override var headingFontColor: UIColor {
        didSet {
            self.itemName.textColor = headingFontColor
            self.dottedLineImg.tintColor = headingFontColor
        }
    }
    
    override var descriptionFontColor: UIColor {
        didSet {
            self.itemDescription.textColor = descriptionFontColor
        }
    }
    
    override var valueFontColor: UIColor {
        didSet {
            for subView in self.itemValueContainer.subviews {
                if let label = subView as? UILabel {
                    label.textColor = valueFontColor
                }
            }
        }
    }
    
    override var itemNameFontSize: CGFloat {
        didSet {
            self.itemName.font = self.itemNameFontStyle.withSize(itemNameFontSize)
        }
    }
    override var itemDescriptionFontSize: CGFloat {
        didSet {
            self.itemDescription.font = self.itemDescriptionFontStyle.withSize(itemDescriptionFontSize)
        }
    }
    override var itemValueFontSize: CGFloat {
        didSet {
            if let lbl = self.itemValueContainer.arrangedSubviews.first as? UILabel {
                let newWidth = ((columnWidth * itemValueFontSize) / lbl.font.pointSize)
                columnWidth = newWidth
            }
            for subView in itemValueContainer.arrangedSubviews {
                if let label = subView as? UILabel {
                    label.font = itemValueFontStyle.withSize(itemValueFontSize)
                }
            }
        }
    }
    
    override var itemNameFontStyle: UIFont {
        didSet {
            self.itemName.font = itemNameFontStyle.withSize(self.itemNameFontSize)
        }
    }
    override var itemDescriptionFontStyle: UIFont {
        didSet {
            self.itemDescription.font = itemDescriptionFontStyle.withSize(self.itemDescriptionFontSize)
        }
    }
    override var itemValueFontStyle: UIFont{
        didSet {
            if let lbl = self.itemValueContainer.arrangedSubviews.first as? UILabel {
                let newWidth = ((columnWidth * itemValueFontSize) / lbl.font.pointSize)
                columnWidth = newWidth
            }
            for subView in itemValueContainer.arrangedSubviews {
                if let label = subView as? UILabel {
                    label.font = itemValueFontStyle.withSize(itemValueFontSize)
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.doInitSetup()
    }
    
    private func doInitSetup() {
        
    }
}

// MARK: - Private Method
extension Type13Menu {
    private func setNewColumnWidth() {
        for subView in self.itemValueContainer.arrangedSubviews {
            if let label = subView as? UILabel {
                let widthConstraint = label.constraints.filter({ $0.identifier == "labelWidthConstraint" })
                if let widthAnchor = widthConstraint.first {
                    widthAnchor.constant = columnWidth
                }
            }
        }
        self.layoutIfNeeded()
    }
    
    private func addDataInContainer() {
        if let name = data?.itemName {
            self.itemName.text = name
            self.itemName.font = self.itemNameFontStyle.withSize(itemNameFontSize)
            self.itemName.textColor = self.headingFontColor
        }
        if let description = data?.description {
            self.itemDescription.text = description
            self.itemDescription.font = self.itemDescriptionFontStyle.withSize(itemDescriptionFontSize)
            self.itemDescription.textColor = self.descriptionFontColor
        } else {
            self.itemDescription.text = ""
        }
        if let values = data?.values, values.count > 0 {
            for index in 0...noOfColumns - 1 {
                let newLbl = UILabel()
                newLbl.numberOfLines = 1
                newLbl.lineBreakMode = .byWordWrapping
                newLbl.textColor = self.valueFontColor
                newLbl.font = self.itemValueFontStyle.withSize(itemValueFontSize)
                if let value = values["\(index + 1)"] {
                    newLbl.text = value
                }
                self.itemValueContainer.addArrangedSubview(newLbl)
                newLbl.translatesAutoresizingMaskIntoConstraints = false
                let widthConstraint = newLbl.widthAnchor.constraint(equalToConstant: self.columnWidth)
                widthConstraint.identifier = "labelWidthConstraint"
                widthConstraint.isActive = true
                if let newWidth = newLbl.getNeededWidth() {
                    if newWidth > self.columnWidth {
                        self.columnWidth = newWidth
                        widthConstraint.constant = newWidth
                        NotificationCenter.default.post(name: .columnWidthChange, object: nil, userInfo: ["columnWidth": newWidth])
                    }
                }
            }
        }
        self.layoutIfNeeded()
    }
}
