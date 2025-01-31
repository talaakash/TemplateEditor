import UIKit

enum ImageResolution {
    case SD
    case HD

    var scale: CGFloat {
        switch self {
        case .SD:
            return 0.5
        case .HD:
            return 1.0
        }
    }
}

enum TaskType{
    case adding
    case changing
    case bg
    case layered
    
    var value: Int {
        switch self {
        case .adding:
            return 1
        case .changing:
            return 2
        case .bg:
            return 3
        case .layered:
            return 4
        }
    }
}

enum EditType {
    case move, delete, copy, backgroundColor, flipH, crop, flipV, change, layered, blur, opacity, shadow, adjustments, blendImage, lock, fontChange, fontSize, editFont, fontColor, editContent, changeSize, adjustSpace, tintColor
    
    var getIcon: String {
        switch self {
        case .delete:
            return "trash"
        case .copy:
            return "copy"
        case .flipH:
            return "reflect_horizontal"
        case .flipV:
            return "reflect_vertical"
        case .change:
            return "change"
        case .layered:
            return "layered"
        case .lock:
            return "lock"
        case .fontChange:
            return "fonts"
        case .editFont:
            return "fontEdit"
        case .fontColor:
            return "color"
        case .blur:
            return "blur"
        case .opacity:
            return "opacity"
        case .shadow:
            return "shadow"
        case .editContent:
            return "fontEdit"
        case .changeSize:
            return "changeSize"
        case .backgroundColor:
            return "backgroundColor"
        case .adjustments:
            return "adjustments"
        case .blendImage:
            return "blend"
        case .move:
            return "nudge"
        case .tintColor:
            return "color"
        case .fontSize:
            return "fontSize"
        case .crop:
            return "crop"
        case .adjustSpace:
            return "shadowWidth"
        }
    }
    
    var name: String {
        switch self {
        case .move:
            return "moveOption".localize()
        case .delete:
            return "deleteOption".localize()
        case .copy:
            return "copyOption".localize()
        case .backgroundColor:
            return "backgroundColorOption".localize()
        case .flipH:
            return "flipHOption".localize()
        case .flipV:
            return "flipVOption".localize()
        case .change:
            return "changeOption".localize()
        case .layered:
            return "layeredOption".localize()
        case .blur:
            return "blurEffectTitle".localize()
        case .opacity:
            return "opacityEffectTitle".localize()
        case .shadow:
            return "shadowAdjust".localize()
        case .adjustments:
            return "adjustmentsOption".localize()
        case .blendImage:
            return "blendOption".localize()
        case .lock:
            return "lockOption".localize()
        case .fontChange:
            return "fontStyleOption".localize()
        case .editFont:
            return "editTextOption".localize()
        case .fontColor:
            return "fontColorOption".localize()
        case .editContent:
            return "editContentOption".localize()
        case .changeSize:
            return "changeSizeOption".localize()
        case .tintColor:
            return "tintColorOption".localize()
        case .fontSize:
            return "fontSizeTitle".localize()
        case .crop:
            return "cropOption".localize()
        case .adjustSpace:
            return "spacingOption".localize()
        }
    }
    
    var isPremiumFeature: Bool {
        switch self {
        case .move:
            return false
        case .delete:
            return false
        case .copy:
            return false
        case .backgroundColor:
            return false
        case .flipH:
            return false
        case .flipV:
            return false
        case .change:
            return false
        case .layered:
            return false
        case .blur:
            return true
        case .opacity:
            return false
        case .shadow:
            return false
        case .adjustments:
            return true
        case .blendImage:
            return true
        case .lock:
            return false
        case .fontChange:
            return true
        case .editFont:
            return false
        case .fontColor:
            return false
        case .editContent:
            return false
        case .changeSize:
            return true
        case .tintColor:
            return false
        case .fontSize:
            return false
        case .crop:
            return true
        case .adjustSpace:
            return false
        }
    }
}

enum EffectType {
    case blur
    case opacity
    case fontSize
    
    var effectName: String {
        switch self {
        case .blur:
            return "blurEffectTitle".localize()
        case .opacity:
            return "opacityEffectTitle".localize()
        case .fontSize:
            return "fontSizeTitle".localize()
        }
    }
}

enum ComponentType: String, CaseIterable {
    case menuBox = "menuBox"
    case image = "image"
    case label = "label"
    case shape = "shape"
    case page = "page"
    
    var icon: String {
        switch self {
        case .label:
            return "text"
        case .image:
            return "picture"
        case .menuBox:
            return "menu"
        case .shape:
            return "shape"
        case .page:
            return "page"
        }
    }
    
    var localName: String {
        switch self {
        case .label:
            return "addTextBtnTitle".localize()
        case .image:
            return "choseImgBtnTitle".localize()
        case .menuBox:
            return "menuItemBtnTitle".localize()
        case .shape:
            return "addShapeBtnTitle".localize()
        case .page:
            return "addPageBtnTitle".localize()
        }
    }
    
    var isPremiumFeature: Bool {
        switch self {
        case .label:
            return false
        case .image:
            return false
        case .menuBox:
            return false
        case .shape:
            return false
        case .page:
            return true
        }
    }
}

enum ColorType {
    case backgroundColor
    case textColor
    case tintColor
    
    var rawValue: Int {
        switch self {
        case .backgroundColor:
            return 0
        case .textColor:
            return 1
        case .tintColor:
            return 2
        }
    }
}

enum ResizeOption: Int, CaseIterable {
    case itemName = 0
    case itemDescription = 1
    case itemValue = 2
    
    var iconName: String {
        switch self {
        case .itemName:
            return "heading"
        case .itemDescription:
            return "description"
        case .itemValue:
            return "price"
        }
    }
    
    var name: String {
        switch self {
        case .itemName:
            return "menuHeading".localize()
        case .itemDescription:
            return "menuDescription".localize()
        case .itemValue:
            return "menuCost".localize()
        }
    }
}

enum ActionType {
    case close, check
}

enum BlendMode: String, CaseIterable {
    case normal = ""
    case multiply = "multiplyBlendMode"
    case screen = "screenBlendMode"
    case overlay = "overlayBlendMode"
    case darken = "darkenBlendMode"
    case lighten = "lightenBlendMode"
    case colorDodge = "colorDodgeBlendMode"
    case colorBurn = "colorBurnBlendMode"
    case softLight = "softLightBlendMode"
    case hardLight = "hardLightBlendMode"
    
    var iconName: String {
        switch self {
        case .normal:
            return "normalBlend"
        case .multiply:
            return "multiplyBlend"
        case .screen:
            return "screenBlend"
        case .overlay:
            return "overlayBlend"
        case .darken:
            return "darkenBlend"
        case .lighten:
            return "lightenBlend"
        case .colorDodge:
            return "colorDodgeBlend"
        case .colorBurn:
            return "colorBurnBlend"
        case .softLight:
            return "softLightBlend"
        case .hardLight:
            return "hardLightBlend"
        }
    }
    
    var name: String {
        switch self {
        case .normal:
            return "normalBlend".localize()
        case .multiply:
            return "multiplyBlend".localize()
        case .screen:
            return "screenBlend".localize()
        case .overlay:
            return "overlayBlend".localize()
        case .darken:
            return "darkenBlend".localize()
        case .lighten:
            return "lightenBlend".localize()
        case .colorDodge:
            return "colorDogeBlend".localize()
        case .colorBurn:
            return "colorBurnBlend".localize()
        case .softLight:
            return "softLightBlend".localize()
        case .hardLight:
            return "hardLightBlend".localize()
        }
    }
}

enum ImageFilters: CaseIterable {
    case brightness, contrast, saturation, exposure, vibrance, warmth, vignette
    
    var iconName: String {
        switch self {
        case .brightness:
            return "brightness"
        case .contrast:
            return "contrast"
        case .saturation:
            return "saturation"
        case .exposure:
            return "exposure"
        case .vibrance:
            return "vibrance"
        case .warmth:
            return "warmth"
        case .vignette:
            return "vignette"
        }
    }
    
    var title: String {
        switch self {
        case .brightness:
            return "brightnessAdjust".localize()
        case .contrast:
            return "contrastAdjust".localize()
        case .saturation:
            return "saturationAdjust".localize()
        case .exposure:
            return "exposureAdjust".localize()
        case .vibrance:
            return "vibranceAdjust".localize()
        case .warmth:
            return "warmthAdjust".localize()
        case .vignette:
            return "vignetteAdjust".localize()
        }
    }
}

enum FilePickType: CaseIterable {
    case gallery, file, camera
    
    var iconName: String {
        switch self {
        case .gallery:
            return "gallery"
        case .file:
            return "file"
        case .camera:
            return "camera"
        }
    }
    
    var name: String {
        switch self {
        case .gallery:
            return "galleryOption".localize()
        case .file:
            return "fileOption".localize()
        case .camera:
            return "cameraOption".localize()
        }
    }
}

enum MenuStyle: Int, CaseIterable {
    case type1 = 1
    case type2 = 2
    case type3 = 3
    case type4 = 4
    case type5 = 5
    case type6 = 6
    case type7 = 7
    case type8 = 8
    case type9 = 9
    case type10 = 10
    case type11 = 11
    case type12 = 12
    case type13 = 13
    
    var iconName: String {
        switch self {
        case .type1:
            return "type1Menu"
        case .type2:
            return "type2Menu"
        case .type3:
            return "type3Menu"
        case .type4:
            return "type4Menu"
        case .type5:
            return "type5Menu"
        case .type6:
            return "type6Menu"
        case .type7:
            return "type7Menu"
        case .type8:
            return "type8Menu"
        case .type9:
            return "type9Menu"
        case .type10:
            return "type10Menu"
        case .type11:
            return "type11Menu"
        case .type12:
            return "type12Menu"
        case .type13:
            return "type13Menu"
        }
    }
    
    var itemNameStyle: UIFont {
        switch self {
        case .type1:
            return UIFont(name: "Lato-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        case .type2:
            return UIFont(name: "InriaSans-Light", size: 24) ?? UIFont.systemFont(ofSize: 24)
        case .type3:
            return UIFont(name: "Lora-Regular", size: 8.73) ?? UIFont.systemFont(ofSize: 8.73)
        case .type4:
            return UIFont(name: "Lora-Regular_Bold", size: 20) ?? UIFont.systemFont(ofSize: 20)
        case .type5:
            return UIFont(name: "Lora-Regular_Bold", size: 20) ?? UIFont.systemFont(ofSize: 20)
        case .type6:
            return UIFont(name: "Lato-Regular", size: 10.62) ?? UIFont.systemFont(ofSize: 10.62)
        case .type7:
            return UIFont(name: "Lora-Regular_Medium", size: 24) ?? UIFont.systemFont(ofSize: 24)
        case .type8:
            return UIFont(name: "Lora-Regular_Medium", size: 24) ?? UIFont.systemFont(ofSize: 24)
        case .type9:
            return UIFont(name: "InriaSans-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20)
        case .type10:
            return UIFont(name: "Inter-Regular_Medium", size: 32) ?? UIFont.systemFont(ofSize: 32)
        case .type11:
            return UIFont(name: "InriaSans-Bold", size: 32) ?? UIFont.systemFont(ofSize: 32)
        case .type12:
            return UIFont(name: "Poppins-Regular", size: 20) ?? UIFont.systemFont(ofSize: 20)
        case .type13:
            return UIFont(name: "InriaSans-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20)
        }
    }
    
    var itemDescriptionStyle: UIFont {
        switch self {
        case .type1:
            return UIFont(name: "Lato-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        case .type2:
            return UIFont(name: "Lato-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        case .type3:
            return UIFont(name: "Lato-Regular", size: 7.24) ?? UIFont.systemFont(ofSize: 7.24)
        case .type4:
            return UIFont(name: "Lato-Regular", size: 20) ?? UIFont.systemFont(ofSize: 20)
        case .type5:
            return UIFont(name: "Lato-Regular", size: 20) ?? UIFont.systemFont(ofSize: 20)
        case .type6:
            return UIFont(name: "Lato-Regular", size: 5.31) ?? UIFont.systemFont(ofSize: 5.31)
        case .type7:
            return UIFont(name: "Lora-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        case .type8:
            return UIFont(name: "Lora-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        case .type9:
            return UIFont(name: "Lato-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        case .type10:
            return UIFont(name: "Lato-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        case .type11:
            return UIFont(name: "InriaSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        case .type12:
            return UIFont(name: "Poppins-Regular", size: 14) ?? UIFont.systemFont(ofSize: 14)
        case .type13:
            return UIFont(name: "Lato-Regular", size: 12) ?? UIFont.systemFont(ofSize: 12)
        }
    }
    
    var itemValueFontStyle: UIFont {
        switch self {
        case .type1:
            return UIFont(name: "Lato-Black", size: 12) ?? UIFont.systemFont(ofSize: 12)
        case .type2:
            return UIFont(name: "InriaSans-Regular", size: 24) ?? UIFont.systemFont(ofSize: 24)
        case .type3:
            return UIFont(name: "Lora-Regular", size: 11.64) ?? UIFont.systemFont(ofSize: 11.64)
        case .type4:
            return UIFont(name: "Lora-Regular_Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        case .type5:
            return UIFont(name: "Lora-Regular_Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        case .type6:
            return UIFont(name: "Lato-Bold", size: 10.62) ?? UIFont.systemFont(ofSize: 10.62)
        case .type7:
            return UIFont(name: "Lora-Regular_Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        case .type8:
            return UIFont(name: "Lora-Regular_Bold", size: 16) ?? UIFont.systemFont(ofSize: 16)
        case .type9:
            return UIFont(name: "InriaSans-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20)
        case .type10:
            return UIFont(name: "Inter-Regular_Medium", size: 24) ?? UIFont.systemFont(ofSize: 24)
        case .type11:
            return UIFont(name: "InriaSans-Regular", size: 16) ?? UIFont.systemFont(ofSize: 16)
        case .type12:
            return UIFont(name: "Poppins-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20)
        case .type13:
            return UIFont(name: "InriaSans-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20)
        }
    }
    
    var itemNameFontSize: CGFloat {
        switch self {
        case .type1:
            return 16
        case .type2:
            return 24
        case .type3:
            return 8.73
        case .type4:
            return 20
        case .type5:
            return 20
        case .type6:
            return 10.62
        case .type7:
            return 24
        case .type8:
            return 24
        case .type9:
            return 20
        case .type10:
            return 32
        case .type11:
            return 32
        case .type12:
            return 20
        case .type13:
            return 20
        }
    }
    
    var itemDescriptionFontSize: CGFloat {
        switch self {
        case .type1:
            return 12
        case .type2:
            return 12
        case .type3:
            return 7.24
        case .type4:
            return 20
        case .type5:
            return 20
        case .type6:
            return 5.31
        case .type7:
            return 16
        case .type8:
            return 16
        case .type9:
            return 12
        case .type10:
            return 12
        case .type11:
            return 16
        case .type12:
            return 14
        case .type13:
            return 12
        }
    }
    
    var itemValueFontSize: CGFloat {
        switch self {
        case .type1:
            return 12
        case .type2:
            return 24
        case .type3:
            return 11.64
        case .type4:
            return 16
        case .type5:
            return 16
        case .type6:
            return 10.62
        case .type7:
            return 16
        case .type8:
            return 16
        case .type9:
            return 20
        case .type10:
            return 24
        case .type11:
            return 16
        case .type12:
            return 20
        case .type13:
            return 20
        }
    }
    
    var isPremium: Bool {
        switch self {
        case .type1:
            return false
        case .type2:
            return false
        case .type3:
            return true
        case .type4:
            return true
        case .type5:
            return false
        case .type6:
            return false
        case .type7:
            return false
        case .type8:
            return true
        case .type9:
            return false
        case .type10:
            return false
        case .type11:
            return false
        case .type12:
            return true
        case .type13:
            return false
        }
    }
}

enum ShadowOption: CaseIterable {
    case opacity, radius, width, height
    
    var iconName: String {
        switch self {
        case .opacity:
            return "shadowOpacity"
        case .radius:
            return "shadowRadius"
        case .width:
            return "shadowWidth"
        case .height:
            return "shadowHeight"
        }
    }
    
    var name: String {
        switch self {
        case .opacity:
            return "shadowOpacity".localize()
        case .radius:
            return "shadowRadius".localize()
        case .width:
            return "shadowWidth".localize()
        case .height:
            return "shadowHeight".localize()
        }
    }
}

enum RearrangeOption: Int {
    case up = 0
    case down = 1
    case left = 2
    case right = 3
}

enum LockOptions: CaseIterable {
    case interaction, change, movement
    
    var iconName: String {
        switch self {
        case .interaction:
            return "intraction"
        case .change:
            return "change"
        case .movement:
            return "nudge"
        }
    }
    
    var name: String {
        switch self {
        case .interaction:
            return "interactionLock".localize()
        case .change:
            return "changeLock".localize()
        case .movement:
            return "movementLock".localize()
        }
    }
}

enum AddPageType: CaseIterable {
    case newPage, copyPage, deletePage
    
    var iconName: String {
        switch self {
        case .newPage:
            return "intraction"
        case .copyPage:
            return "intraction"
        case .deletePage:
            return "intraction"
        }
    }
    
    var name: String {
        switch self {
        case .newPage:
            return "newPage".localize()
        case .copyPage:
            return "copyPage".localize()
        case .deletePage:
            return "deletePage".localize()
        }
    }
}

enum Spacing: CaseIterable {
    case valueSpace, valueWidth
    
    var iconName: String {
        switch self {
        case .valueSpace:
            return "intraction"
        case .valueWidth:
            return "intraction"
        }
    }
    
    var name: String {
        switch self {
        case .valueSpace:
            return "itemBetweenSpace".localize()
        case .valueWidth:
            return "itemWidthSpace".localize()
        }
    }
}

enum SaveContentSize: Float {
    case normal = 3
    case medium = 6
    case large = 9
}
