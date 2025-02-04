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
var isUserIsPaid = false

class Theme {
    static var primaryButtonColor = UIColor(hex: "#F5C000")
    static var secondaryButtonColor = UIColor(hex: "#3535350A")
    static var primaryTextColor = UIColor(hex: "#353535")
    static var secondaryTextColor = UIColor(hex: "#C29800")
    static var primaryBorderColor = UIColor(hex: "#F5C00033")
    static var secondaryBorderColor = UIColor(hex: "#3535351A")
}
