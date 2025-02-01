//
//  Constants.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

typealias ErrorCallBack = (String) -> Void
typealias SuccessCallBack = () -> Void


let packageBundle = Bundle(for: EditorViewController.self)
let editorStoryBoard = UIStoryboard(name: "Editor", bundle: packageBundle)

var makeEditorScreenSecure: Bool = true

let isIpad = UIDevice.current.userInterfaceIdiom == .pad

let isUserIsAdmin = true


class ProjectSelectedOptions {
    static var componentsTypes: [GenericModel<ComponentType>] = ComponentType.allCases.compactMap({ component in
        return GenericModel(type: component)
    })
    static var editOptions: [GenericModel<EditType>] = EditType.allCases.compactMap({ type in
        return GenericModel(type: type)
    })
    static var rearrangeOptions: [GenericModel<RearrangeOption>] = RearrangeOption.allCases.compactMap({ option in
        return GenericModel(type: option)
    })
    static var lockOptions: [GenericModel<LockOptions>] = LockOptions.allCases.compactMap({ option in
        return GenericModel(type: option)
    })
}

//MARK: Temp resource
extension UIColor {
    static let fontColorC29800 = UIColor(named: "fontColorC29800", in: packageBundle, compatibleWith: nil)
    static let fontColor303030 = UIColor(named: "fontColor303030", in: packageBundle, compatibleWith: nil)
    static let fontColor353535 = UIColor(named: "fontColor353535", in: packageBundle, compatibleWith: nil)
    static let buttonBgF5C000 = UIColor(named: "buttonBgF5C000", in: packageBundle, compatibleWith: nil)
    static let borderColorC29800 = UIColor(named: "borderColorC29800", in: packageBundle, compatibleWith: nil)
}

class UserDefaultsKeys {
    static let imagesNames = "imagesNames"
    static let storedJsonNames = "storedJsonNames"
    static let selectedLanguage = "selectedLanguage"
    static let isPremiumUnlocked = "isPremiumUnlocked"
    static let transactionId = "transactionId"
    static let purchasedPlanId = "purchasedPlanId"
    static let currentUserId = "currentUserId"
    static let launchCountInV = "launchCountInV"
}

class ViewControllers {
    static let menuEditorVCStoryBoardID = "MenuEditorVC"
    static let imageQualityInputControllerStoryBoardID = "ImageQualityInputController"
    static let menuStyleSelectionStoryBoardID = "MenuStyleSelection"
    static let exportOptionsStoryBoardID = "ExportOptions"
    static let qrPreviewerStoryBoardID = "QrPreviewer"
}
