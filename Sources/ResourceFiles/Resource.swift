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
    static let homeVCStoryBoardID = "HomeVC"
    static let editorVCStoryBoardID = "EditorVC"
    static let menuEditorVCStoryBoardID = "MenuEditorVC"
    static let paymentVCStoryBoardID = "PaymentVC"
    static let imageQualityInputControllerStoryBoardID = "ImageQualityInputController"
    static let menuStyleSelectionStoryBoardID = "MenuStyleSelection"
    static let noInternetConnectionStoryBoardID = "NoInternetConnection"
    static let mainTabControllerStoryBoardID = "MainTabController"
    static let loginVCStoryBoardID = "LoginVC"
    static let forgetPasswordVCStoryBoardID = "ForgetPasswordVC"
    static let signupVCStoryBoardID = "SignupVC"
    static let exportOptionsStoryBoardID = "ExportOptions"
    static let qrPreviewerStoryBoardID = "QrPreviewer"
}
