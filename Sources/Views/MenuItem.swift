import Foundation
import UIKit

class MenuItem: UIView {
    @IBOutlet private weak var itemName: UILabel!
    @IBOutlet private weak var itemDescription: UILabel!
    @IBOutlet private weak var itemValueContainer: UIStackView!
    
    var noOfColumns: Int = 0
    var columnWidth: CGFloat = .zero {
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
    var data: MenuItemDetails? {
        didSet {
            self.addDataInContainer()
        }
    }
    var fontColor: UIColor = .black {
        didSet {
            self.itemName.textColor = fontColor
            self.itemDescription.textColor = fontColor
            for subView in self.itemValueContainer.subviews {
                if let label = subView as? UILabel {
                    label.textColor = fontColor
                }
            }
        }
    }
    
    var itemNameFontSize: CGFloat = 19 {
        didSet {
            self.itemName.font = self.itemName.font.withSize(itemNameFontSize)
        }
    }
    var itemDescriptionFontSize: CGFloat = 17 {
        didSet {
            self.itemDescription.font = self.itemDescription.font.withSize(itemDescriptionFontSize)
        }
    }
    var itemValueFontSize: CGFloat = 17 {
        didSet {
            if let lbl = self.itemValueContainer.arrangedSubviews.first as? UILabel {
                let newWidth = ((columnWidth * itemValueFontSize) / lbl.font.pointSize)
                columnWidth = newWidth
            }
            for subView in itemValueContainer.arrangedSubviews {
                if let label = subView as? UILabel {
                    label.font = label.font.withSize(itemValueFontSize)
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        doInitSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        doInitSetup()
    }
    
    private func doInitSetup() {

    }
}

// MARK: - Private Method
extension MenuItem {
    private func addDataInContainer() {
        if let name = data?.itemName {
            self.itemName.text = name
            self.itemName.font = self.itemName.font.withSize(itemNameFontSize)
            self.itemName.textColor = fontColor
        }
        if let description = data?.description {
            self.itemDescription.text = description
            self.itemDescription.font = self.itemDescription.font.withSize(itemDescriptionFontSize)
            self.itemDescription.textColor = fontColor
        } else {
            self.itemDescription.text = ""
        }
        if let values = data?.values, values.count > 0 {
            for index in 0...noOfColumns - 1 {
                let newLbl = UILabel()
                newLbl.numberOfLines = 0
                newLbl.lineBreakMode = .byWordWrapping
                newLbl.textColor = fontColor
                newLbl.font = newLbl.font.withSize(itemValueFontSize)
                if let value = values["\(index + 1)"] {
                    newLbl.text = value
                }
                self.itemValueContainer.addArrangedSubview(newLbl)
            }
        }
    }
}
