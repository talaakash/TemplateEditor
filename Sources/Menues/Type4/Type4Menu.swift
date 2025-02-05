//
//  Type4Menu.swift
//  Pods
//
//  Created by Akash Tala on 05/02/25.
//


import UIKit

class Type4Menu: ItemView {
    @IBOutlet private weak var itemName: UILabel!
    @IBOutlet private weak var itemDescription: UILabel!
    @IBOutlet private weak var itemValue: UILabel!
    
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
            self.itemValue.textColor = valueFontColor
        }
    }
    
    override var itemNameFontSize: CGFloat {
        didSet {
            self.itemName.font = self.itemNameFontStyle.withSize(itemNameFontSize)
        }
    }
    override var itemDescriptionFontSize: CGFloat {
        didSet {
            self.itemDescription.font = self.itemDescriptionFontStyle.withSize(self.itemDescriptionFontSize)
        }
    }
    override var itemValueFontSize: CGFloat {
        didSet {
            self.itemValue.font = self.itemValueFontStyle.withSize(itemValueFontSize)
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
            self.itemValue.font = self.itemValueFontStyle.withSize(self.itemValueFontSize)
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
extension Type4Menu {
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
            if let text = values.first?.value {
                self.itemValue.text = text
                self.itemValue.textColor = self.valueFontColor
                self.itemValue.font = self.itemValueFontStyle.withSize(itemValueFontSize)
            }
        }
        self.layoutIfNeeded()
    }
}
