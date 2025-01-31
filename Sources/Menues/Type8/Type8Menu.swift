import UIKit

class Type8Menu: ItemView {
    @IBOutlet private weak var itemName: UILabel!
    @IBOutlet private weak var itemDescription: UILabel!
    @IBOutlet private weak var itemValue: UILabel!
    @IBOutlet private weak var separatorView: UIView!
    @IBOutlet private weak var itemQuantity: UILabel!
    @IBOutlet private weak var separatorLeading: NSLayoutConstraint!
    @IBOutlet private weak var separatorTrailing: NSLayoutConstraint!
    
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
    
    override var descriptionFontColor: UIColor {
        didSet {
            self.itemDescription.textColor = descriptionFontColor
        }
    }
    
    override var valueFontColor: UIColor {
        didSet {
            self.itemValue.textColor = self.valueFontColor
            self.itemQuantity.textColor = self.valueFontColor
            self.separatorView.backgroundColor = self.valueFontColor
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
            self.itemValue.font = self.itemValueFontStyle.withSize(itemValueFontSize)
            self.itemQuantity.font = self.itemValueFontStyle.withSize(itemValueFontSize)
        }
    }
    
    override var itemNameFontStyle: UIFont {
        didSet {
            self.itemName.font = itemNameFontStyle.withSize(self.itemNameFontSize)
        }
    }
    override var itemDescriptionFontStyle: UIFont{
        didSet {
            self.itemDescription.font = itemDescriptionFontStyle.withSize(self.itemDescriptionFontSize)
        }
    }
    override var itemValueFontStyle: UIFont{
        didSet {
            self.itemValue.font = self.itemValueFontStyle.withSize(itemValueFontSize)
            self.itemQuantity.font = self.itemValueFontStyle.withSize(itemValueFontSize)
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
extension Type8Menu {
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
        }
        if let values = data?.values, values.count > 0 {
            if let quantity = values["1"] {
                self.itemQuantity.text = quantity
                self.itemQuantity.textColor = self.valueFontColor
                self.itemQuantity.font = self.itemValueFontStyle.withSize(itemValueFontSize)
            } else {
                self.itemQuantity.text = ""
                self.separatorView.isHidden = true
            }
            if let itemValue = values["2"] {
                self.itemValue.text = itemValue
                self.itemValue.textColor = self.valueFontColor
                self.itemValue.font = self.itemValueFontStyle.withSize(itemValueFontSize)
            } else {
                self.itemValue.text = ""
                self.separatorView.isHidden = true
                self.separatorView.constraints.first?.constant = 0
                self.separatorLeading.constant = 0
                self.separatorTrailing.constant = 0
            }
        }
        self.layoutIfNeeded()
    }
}
