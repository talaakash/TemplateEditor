//
//  Models.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import Foundation
import UIKit

public struct DynamicUIData: Decodable {
    public let superViewWidth: CGFloat
    public let superViewHeight: CGFloat
    public let preview_img: String?
    
    public let outputWidth: Float
    public let outputHeight: Float
   
    public var elements: [String: [UIElement]]
}

public struct UIElement: Decodable {
    public let type: String
    
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
    public var url: String?
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

// Generic Model for getting component from project
public protocol EnumType { }

public struct GenericModel<T: EnumType> {
    public var type: T
    public var name: String?
    public var icon: String?
    public var isPremium: Bool?
    
    public init(type: T, name: String? = nil, icon: String? = nil, isPremium: Bool? = nil) {
        self.type = type
        self.name = name
        self.icon = icon
        self.isPremium = isPremium
    }
}
