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

enum TaskType {
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

public enum EditType: EnumType, CaseIterable {
    case move, delete, copy, backgroundColor, flipH, crop, flipV, change, layered, blur, opacity, shadow, adjustments, blendImage, lock, fontChange, fontSize, editFont, fontColor, editContent, changeSize, adjustSpace, tintColor
    
    var getIcon: UIImage? {
        switch self {
        case .delete:
            return UIImage(named: "trash", in: packageBundle, with: .none)
        case .copy:
            return UIImage(named: "copy", in: packageBundle, with: .none)
        case .flipH:
            return UIImage(named: "reflect_horizontal", in: packageBundle, with: .none)
        case .flipV:
            return UIImage(named: "reflect_vertical", in: packageBundle, with: .none)
        case .change:
            return UIImage(named: "change", in: packageBundle, with: .none)
        case .layered:
            return UIImage(named: "layered", in: packageBundle, with: .none)
        case .lock:
            return UIImage(named: "lock", in: packageBundle, with: .none)
        case .fontChange:
            return UIImage(named: "fonts", in: packageBundle, with: .none)
        case .editFont:
            return UIImage(named: "fontEdit", in: packageBundle, with: .none)
        case .fontColor:
            return UIImage(named: "color", in: packageBundle, with: .none)
        case .blur:
            return UIImage(named: "blur", in: packageBundle, with: .none)
        case .opacity:
            return UIImage(named: "opacity", in: packageBundle, with: .none)
        case .shadow:
            return UIImage(named: "shadow", in: packageBundle, with: .none)
        case .editContent:
            return UIImage(named: "fontEdit", in: packageBundle, with: .none)
        case .changeSize:
            return UIImage(named: "changeSize", in: packageBundle, with: .none)
        case .backgroundColor:
            return UIImage(named: "backgroundColor", in: packageBundle, with: .none)
        case .adjustments:
            return UIImage(named: "adjustments", in: packageBundle, with: .none)
        case .blendImage:
            return UIImage(named: "blend", in: packageBundle, with: .none)
        case .move:
            return UIImage(named: "nudge", in: packageBundle, with: .none)
        case .tintColor:
            return UIImage(named: "color", in: packageBundle, with: .none)
        case .fontSize:
            return UIImage(named: "fontSize", in: packageBundle, with: .none)
        case .crop:
            return UIImage(named: "crop", in: packageBundle, with: .none)
        case .adjustSpace:
            return UIImage(named: "shadowWidth", in: packageBundle, with: .none)
        }
    }
    
    var name: String {
        switch self {
        case .move:
            return "Move"
        case .delete:
            return "Delete"
        case .copy:
            return "Copy"
        case .backgroundColor:
            return "BG Color"
        case .flipH:
            return "Flip H"
        case .flipV:
            return "Flip V"
        case .change:
            return "Change"
        case .layered:
            return "Layered"
        case .blur:
            return "Blur"
        case .opacity:
            return "Opacity"
        case .shadow:
            return "Shadow"
        case .adjustments:
            return "Adjustments"
        case .blendImage:
            return "Blend Modes"
        case .lock:
            return "Lock Option"
        case .fontChange:
            return "Font Style"
        case .editFont:
            return "Edit Text"
        case .fontColor:
            return "Font Color"
        case .editContent:
            return "Edit Content"
        case .changeSize:
            return "Change Size"
        case .tintColor:
            return "Color"
        case .fontSize:
            return "Font Size"
        case .crop:
            return "Crop"
        case .adjustSpace:
            return "Adjust Space"
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
            return "Blur Effect"
        case .opacity:
            return "Opacity"
        case .fontSize:
            return "Font Size"
        }
    }
}

public enum ComponentType: String, CaseIterable, EnumType {
    case menuBox = "menuBox"
    case image = "image"
    case label = "label"
    case shape = "shape"
    case page = "page"
    
    var icon: UIImage? {
        switch self {
        case .label:
            return UIImage(named: "text", in: packageBundle, with: .none)
        case .image:
            return UIImage(named: "picture", in: packageBundle, with: .none)
        case .menuBox:
            return UIImage(named: "menu", in: packageBundle, with: .none)
        case .shape:
            return UIImage(named: "shape", in: packageBundle, with: .none)
        case .page:
            return UIImage(named: "page", in: packageBundle, with: .none)
        }
    }
    
    var localName: String {
        switch self {
        case .label:
            return "Text"
        case .image:
            return "Image"
        case .menuBox:
            return "Menu"
        case .shape:
            return "Shape"
        case .page:
            return "Add Page"
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

public enum ResizeOption: Int, CaseIterable {
    case itemName = 0
    case itemDescription = 1
    case itemValue = 2
    
    var iconName: UIImage? {
        switch self {
        case .itemName:
            return UIImage(named: "heading", in: packageBundle, with: .none)
        case .itemDescription:
            return UIImage(named: "description", in: packageBundle, with: .none)
        case .itemValue:
            return UIImage(named: "price", in: packageBundle, with: .none)
        }
    }
    
    var name: String {
        switch self {
        case .itemName:
            return "Heading"
        case .itemDescription:
            return "Description"
        case .itemValue:
            return "Value"
        }
    }
}

enum ActionType {
    case close, check
}

public enum BlendMode: String, CaseIterable, EnumType {
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
    
    var iconName: UIImage? {
        switch self {
        case .normal:
            return UIImage(named: "normalBlend", in: packageBundle, with: .none)
        case .multiply:
            return UIImage(named: "multiplyBlend", in: packageBundle, with: .none)
        case .screen:
            return UIImage(named: "screenBlend", in: packageBundle, with: .none)
        case .overlay:
            return UIImage(named: "overlayBlend", in: packageBundle, with: .none)
        case .darken:
            return UIImage(named: "darkenBlend", in: packageBundle, with: .none)
        case .lighten:
            return UIImage(named: "lightenBlend", in: packageBundle, with: .none)
        case .colorDodge:
            return UIImage(named: "colorDodgeBlend", in: packageBundle, with: .none)
        case .colorBurn:
            return UIImage(named: "colorBurnBlend", in: packageBundle, with: .none)
        case .softLight:
            return UIImage(named: "softLightBlend", in: packageBundle, with: .none)
        case .hardLight:
            return UIImage(named: "hardLightBlend", in: packageBundle, with: .none)
        }
    }
    
    var name: String {
        switch self {
        case .normal:
            return "Normal"
        case .multiply:
            return "Multiply"
        case .screen:
            return "Screen"
        case .overlay:
            return "Overlay"
        case .darken:
            return "Darken"
        case .lighten:
            return "Lighten"
        case .colorDodge:
            return "Color Dodge"
        case .colorBurn:
            return "Color Burn"
        case .softLight:
            return "Soft Light"
        case .hardLight:
            return "Hard Light"
        }
    }
}

public enum ImageFilters: CaseIterable, EnumType {
    case brightness, contrast, saturation, exposure, vibrance, warmth, vignette
    
    var iconName: UIImage? {
        switch self {
        case .brightness:
            return UIImage(named: "brightness", in: packageBundle, with: .none)
        case .contrast:
            return UIImage(named: "contrast", in: packageBundle, with: .none)
        case .saturation:
            return UIImage(named: "saturation", in: packageBundle, with: .none)
        case .exposure:
            return UIImage(named: "exposure", in: packageBundle, with: .none)
        case .vibrance:
            return UIImage(named: "vibrance", in: packageBundle, with: .none)
        case .warmth:
            return UIImage(named: "warmth", in: packageBundle, with: .none)
        case .vignette:
            return UIImage(named: "vignette", in: packageBundle, with: .none)
        }
    }
    
    var title: String {
        switch self {
        case .brightness:
            return "Brightness"
        case .contrast:
            return "Contrast"
        case .saturation:
            return "Saturation"
        case .exposure:
            return "Exposure"
        case .vibrance:
            return "Vibrance"
        case .warmth:
            return "Warmth"
        case .vignette:
            return "Vignette"
        }
    }
}

public enum FilePickType: CaseIterable, EnumType {
    case gallery, file, camera
    
    var iconName: UIImage? {
        switch self {
        case .gallery:
            return UIImage(named: "gallery", in: packageBundle, with: .none)
        case .file:
            return UIImage(named: "file", in: packageBundle, with: .none)
        case .camera:
            return UIImage(named: "camera", in: packageBundle, with: .none)
        }
    }
    
    var name: String {
        switch self {
        case .gallery:
            return "Gallery"
        case .file:
            return "File"
        case .camera:
            return "Camera"
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
    
    var iconName: UIImage? {
        switch self {
        case .type1:
            return UIImage(named: "type1Menu", in: packageBundle, with: .none)
        case .type2:
            return UIImage(named: "type2Menu", in: packageBundle, with: .none)
        case .type3:
            return UIImage(named: "type3Menu", in: packageBundle, with: .none)
        case .type4:
            return UIImage(named: "type4Menu", in: packageBundle, with: .none)
        case .type5:
            return UIImage(named: "type5Menu", in: packageBundle, with: .none)
        case .type6:
            return UIImage(named: "type6Menu", in: packageBundle, with: .none)
        case .type7:
            return UIImage(named: "type7Menu", in: packageBundle, with: .none)
        case .type8:
            return UIImage(named: "type8Menu", in: packageBundle, with: .none)
        case .type9:
            return UIImage(named: "type9Menu", in: packageBundle, with: .none)
        case .type10:
            return UIImage(named: "type10Menu", in: packageBundle, with: .none)
        case .type11:
            return UIImage(named: "type11Menu", in: packageBundle, with: .none)
        case .type12:
            return UIImage(named: "type12Menu", in: packageBundle, with: .none)
        case .type13:
            return UIImage(named: "type13Menu", in: packageBundle, with: .none)
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

public enum ShadowOption: CaseIterable, EnumType {
    case opacity, radius, width, height
    
    var iconName: UIImage? {
        switch self {
        case .opacity:
            return UIImage(named: "shadowOpacity", in: packageBundle, with: .none)
        case .radius:
            return UIImage(named: "shadowRadius", in: packageBundle, with: .none)
        case .width:
            return UIImage(named: "shadowWidth", in: packageBundle, with: .none)
        case .height:
            return UIImage(named: "shadowHeight", in: packageBundle, with: .none)
        }
    }
    
    var name: String {
        switch self {
        case .opacity:
            return "Shadow Opacity"
        case .radius:
            return "Shadow Radius"
        case .width:
            return "Shadow Width"
        case .height:
            return "Shadow Height"
        }
    }
}

public enum RearrangeOption: Int, EnumType, CaseIterable {
    case up = 0
    case down = 1
    case left = 2
    case right = 3
}

public enum LockOptions: CaseIterable, EnumType {
    case interaction, change, movement
    
    var iconName: UIImage? {
        switch self {
        case .interaction:
            return UIImage(named: "intraction", in: packageBundle, with: .none)
        case .change:
            return UIImage(named: "change", in: packageBundle, with: .none)
        case .movement:
            return UIImage(named: "nudge", in: packageBundle, with: .none)
        }
    }
    
    var name: String {
        switch self {
        case .interaction:
            return "Interaction Lock"
        case .change:
            return "Change Lock"
        case .movement:
            return "Movement Lock"
        }
    }
}

public enum AddPageType: CaseIterable, EnumType {
    case newPage, copyPage, deletePage
    
    var iconName: UIImage? {
        switch self {
        case .newPage:
            return UIImage(named: "intraction", in: packageBundle, with: .none)
        case .copyPage:
            return UIImage(named: "intraction", in: packageBundle, with: .none)
        case .deletePage:
            return UIImage(named: "intraction", in: packageBundle, with: .none)
        }
    }
    
    var name: String {
        switch self {
        case .newPage:
            return "New Page"
        case .copyPage:
            return "Copy Page"
        case .deletePage:
            return "Delete Page"
        }
    }
}

enum Spacing: CaseIterable {
    case valueSpace, valueWidth
    
    var iconName: UIImage? {
        switch self {
        case .valueSpace:
            return UIImage(named: "intraction", in: packageBundle, with: .none)
        case .valueWidth:
            return UIImage(named: "intraction", in: packageBundle, with: .none)
        }
    }
    
    var name: String {
        switch self {
        case .valueSpace:
            return "Item Between Space"
        case .valueWidth:
            return "Item Width Space"
        }
    }
}

public enum SaveContentSize: Float {
    case normal = 3
    case medium = 6
    case large = 9
}
