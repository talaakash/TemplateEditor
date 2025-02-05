//
//  Type10Menu.swift
//  Pods
//
//  Created by Akash Tala on 05/02/25.
//


import UIKit

class Type10Menu: ItemView {
    @IBOutlet private weak var itemName: UILabel!
    @IBOutlet private weak var itemValueContainer: SeparatorStackView!
    
    var noOfColumns: Int = 0
    override var columnWidth: CGFloat {
        didSet {
            for subView in self.itemValueContainer.arrangedSubviews {
                if let label = subView as? UILabel {
                    let widthConstraint = label.constraints.filter({ $0.identifier == "labelWidthConstraint" })
                    if let widthAnchor = widthConstraint.first {
                        widthAnchor.constant = columnWidth
                    }
                }
            }
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
        }
    }
    override var valueFontColor: UIColor {
        didSet {
            self.itemValueContainer.separatorColor = valueFontColor
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
    override var itemValueFontSize: CGFloat {
        didSet {
            if let lbl = self.itemValueContainer.arrangedSubviews.first as? UILabel {
                let newWidth = ((columnWidth * itemValueFontSize) / lbl.font.pointSize)
                columnWidth = newWidth
            }
            for subView in itemValueContainer.arrangedSubviews {
                if let label = subView as? UILabel {
                    label.font = self.itemValueFontStyle.withSize(itemValueFontSize)
                }
            }
        }
    }
    
    override var itemNameFontStyle: UIFont {
        didSet {
            self.itemName.font = itemNameFontStyle.withSize(self.itemNameFontSize)
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
        self.itemValueContainer.separatorWidth = 2
    }
}

// MARK: - Private Method
extension Type10Menu {
    private func addDataInContainer() {
        self.itemValueContainer.separatorColor = self.valueFontColor
        if let name = data?.itemName {
            self.itemName.text = name
            self.itemName.font = self.itemNameFontStyle.withSize(itemNameFontSize)
            self.itemName.textColor = self.headingFontColor
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
                if index == (noOfColumns - 1), values["\(index + 1)"] == nil {
                    continue
                } else {
                    self.itemValueContainer.addArrangedSubview(newLbl)
                }
            }
        }
        self.layoutIfNeeded()
    }
}

