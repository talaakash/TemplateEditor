//
//  ItemView.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

import UIKit

class ItemView: UIView {
    var itemNameFontSize: CGFloat = 19
    var itemDescriptionFontSize: CGFloat = 17
    var itemValueFontSize: CGFloat = 17
    
    var itemNameFontStyle: UIFont = UIFont.systemFont(ofSize: 19)
    var itemDescriptionFontStyle: UIFont = UIFont.systemFont(ofSize: 17)
    var itemValueFontStyle: UIFont = UIFont.systemFont(ofSize: 17)
    
    var columnWidth: CGFloat = .zero
    var columnSpace: CGFloat = .zero
    var headingFontColor: UIColor = .black
    var descriptionFontColor: UIColor = .black
    var valueFontColor: UIColor = .black
    var data: MenuItemDetails?
}
