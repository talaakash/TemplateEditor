//
//  Models.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import Foundation
import UIKit

struct DynamicUIData: Decodable {
    let superViewWidth: CGFloat
    let superViewHeight: CGFloat
    let preview_img: String?
    
    let outputWidth: Float
    let outputHeight: Float
   
    var elements: [String: [UIElement]]
}

struct UIElement: Decodable {
    let type: String
    
    let x: CGFloat
    let y: CGFloat
    let width: CGFloat
    let height: CGFloat
   
    let movable: Bool?
    let isUserInteractionEnabled: Bool?
    let alpha: Float? // 0.0 to 1.0 //Default 1
    let isDuplicatable: Bool?
    let isRemovable: Bool?
    
    //UI Related Common property
    let cornerRadius: Int?
    let backGroundColor: String?  //Pass HEX Code ///Default .clear
    let rotationAngle: CGFloat?
 
    //Text related property
    let text: String?
    let alignment: Int?
    let textColor: String? //Pass HEX Code ///Default .black
    let fontURL: String?
    let size: CGFloat? // Default 18
    let isEditable: Bool?
    
    // Image related property
    let contentMode: Int?
    var url: String?
    var isLayeredImg: Bool?
    var blendMode: String?
    var blurAlpha: CGFloat?
    var shadowOpacity: Float?
    var shadowRadius: CGFloat?
    var shadowOffsetWidth: CGFloat?
    var shadowOffsetHeight: CGFloat?
    
    // Shape related property
    var tintColor: String?
    
    // Menu related property
    let itemNameFontSize: CGFloat?
    let itemDescriptionFontSize: CGFloat?
    let itemValueFontSize: CGFloat?
    let columnWidth: CGFloat?
    let columnSpace: CGFloat?
    var menuData: [MenuItemDetails]?
    var menuStyle: Int?
    var itemNameFontStyle: String?
    var itemDescriptionFontStyle: String?
    var itemValueFontStyle: String?
    var itemNameTextColor: String?
    var itemDescriptionTextColor: String?
    var itemValueTextColor: String?
}

struct MenuItemDetails: Decodable {
    var itemName: String?
    var description: String?
    var values: [String: String]?
}

