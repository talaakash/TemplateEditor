//
//  ViewController.swift
//  TemplateEditor
//
//  Created by talaakash on 01/31/2025.
//  Copyright (c) 2025 talaakash. All rights reserved.
//

import UIKit
import TemplateEditor

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func getTestData() -> DynamicUIData? {
        let json = [
            "elements": [
              "0": [
                [
                  "y": -3.00307692307695,
                  "width": 326.334358974359,
                  "type": "image",
                  "isUserInteractionEnabled": false,
                  "backGroundColor": "#FFFFFF",
                  "url": "https://firebasestorage.googleapis.com:443/v0/b/dynamicelementdemo.appspot.com/o/images%2F94CF03C5-9649-40C4-9362-7BD20739E5C8.png?alt=media&token=b0a79c16-e6c9-4cf4-b7fb-8f7a710c0926",
                  "x": -3.00307692307692,
                  "alpha": 1,
                  "height": 575.339487179487,
                  "contentMode": 1
                ],
                [
                  "x": 43.6666615804037,
                  "menuStyle": 2,
                  "itemDescriptionFontStyle": "Lato-Regular",
                  "width": 250,
                  "columnWidth": 30,
                  "backGroundColor": "#00000000",
                  "isRemovable": true,
                  "movable": true,
                  "itemNameFontSize": 24,
                  "itemNameFontStyle": "AcademyEngravedLetPlain",
                  "itemValueFontStyle": "Allison-Regular",
                  "isDuplicatable": true,
                  "itemNameTextColor": "#FFFFFF",
                  "itemValueTextColor": "#FFFFFF",
                  "height": 181.66667175293,
                  "type": "menuBox",
                  "y": 193.666659037272,
                  "alpha": 1,
                  "menuData": [
                    [
                      "description": "Tomato sauce, mozzarella, basil",
                      "itemName": "Margherita",
                      "values": [
                        "1": "$2"
                      ]
                    ],
                    [
                      "description": "Tomato sauce, mozzarella, pepperoni",
                      "values": [
                        "1": "$5"
                      ],
                      "itemName": "Pepperoni"
                    ],
                    [
                      "values": [
                        "1": "$7"
                      ],
                      "itemName": "Hawaiian",
                      "description": "Tomato sauce, mozzarella, ham, pineapple"
                    ],
                    [
                      "description": "Tomato sauce, mozzarella, parmesan, gorgonzola, provolone",
                      "itemName": "Four Cheese",
                      "values": [
                        "1": "$1"
                      ]
                    ],
                    [
                      "description": "Olive oil, mozzarella, feta, olives, artichokes, spinach",
                      "values": [
                        "1": "$1"
                      ],
                      "itemName": "Mediterranean"
                    ]
                  ],
                  "itemValueFontSize": 24,
                  "isUserInteractionEnabled": true,
                  "itemDescriptionFontSize": 12
                ],
                [
                  "x": 75.6666742960612,
                  "isUserInteractionEnabled": true,
                  "height": 157.03061449295,
                  "y": 400.984692753525,
                  "contentMode": 0,
                  "width": 169.66667175293,
                  "isRemovable": true,
                  "alpha": 1,
                  "movable": true,
                  "type": "image",
                  "isDuplicatable": true,
                  "url": "https://firebasestorage.googleapis.com:443/v0/b/dynamicelementdemo.appspot.com/o/images%2FCDFE6355-8B9C-419F-93DC-6F7F0352607B.png?alt=media&token=330660f4-2825-4655-b720-6a8e626e865a"
                ],
                [
                  "isEditable": true,
                  "alpha": 1,
                  "fontURL": "ChalkboardSE-Bold",
                  "width": 150,
                  "x": 78.3333384195964,
                  "size": 36.7764472961426,
                  "isDuplicatable": true,
                  "isUserInteractionEnabled": true,
                  "text": "Pizza!",
                  "backGroundColor": "#00000000",
                  "height": 68.6666666666667,
                  "movable": true,
                  "type": "label",
                  "isRemovable": true,
                  "alignment": 1,
                  "textColor": "#32C759",
                  "y": 51.6666666666667
                ]
              ]
            ],
            "preview_img": "https://firebasestorage.googleapis.com:443/v0/b/dynamicelementdemo.appspot.com/o/previews%2F632E1097-4793-47AF-858A-F8AB1668FB10.png?alt=media&token=8dd96495-05a1-46eb-bc17-c7628c1830ae",
            "superViewHeight": 569.333333333333,
            "outputHeight": 5693.33333333333,
            "superViewWidth": 320.328205128205,
            "outputWidth": 3203.28205128205
        ] as [String : Any]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json, options: []),
              let decodedObject = try? JSONDecoder().decode(DynamicUIData.self, from: jsonData) else { return nil}
        return decodedObject
                
    }
    
    @IBAction private func showEditorBtnTapped(_ sender: UIButton) {
        EditController.featureDelegate = self
        EditController.userDelegate = self
        EditController.exportDelegate = self
        let editor = EditController()
        editor.showEditor(from: self.navigationController!, with: getTestData())
    }
}

// MARK: User delegates
extension ViewController: UserDetails {
    func isUserIsPaid() -> Bool {
        // if here passed true then that means user is paid or if passed false then user is free
        return true
    }
    
    func userSelectedPremiumOption() {
        // This occur when user selected premium feature
        debugPrint("You dont have access to it")
    }
}

// MARK: Export related delegate
extension ViewController: ExportDetails {
    func getSaveOption(completion: @escaping (TemplateEditor.ExportOption, TemplateEditor.SaveContentSize) -> Void) {
        completion(.image, .medium)
    }
    
    func forQrCodeGeneration(json: [String : Any], pdfData: Data, pdfUrl: @escaping ((URL, UIImage) -> Void)) {
        pdfUrl(URL(string: "https://www.google.com")!, UIImage())
    }
    
    func exportedJson(json: [String : Any]) {
        print(json)
    }
    
    func exportedImages(images: [UIImage]) {
        print("\(images.count) saved")
    }
    
    func yourQrCode(img: UIImage) {
        
    }
    
    func somethingWentWrong() {
        print("Something went wrong")
    }
}

// MARK: Editor delegates
extension ViewController: EditingTools {
    func giveComponentDetails() -> [TemplateEditor.GenericModel<TemplateEditor.ComponentType>] {
        return []
    }
    
//    func getResizeOptions() -> [TemplateEditor.GenericModel<TemplateEditor.ResizeOption>] {
//        return [
//            GenericModel(type: .itemDescription, name: "Disco"),
//            GenericModel(type: .itemValue, name: "Check")
//        ]
//    }
//    
//    func getMenuSpacingOptions() -> [TemplateEditor.GenericModel<TemplateEditor.Spacing>] {
//        return [
//            GenericModel(type: .valueWidth)
//        ]
//    }
    
//    func getPageOptions() -> [GenericModel<AddPageType>] {
//        return [
//            GenericModel(type: .copyPage),
//            GenericModel(type: .deletePage, name: "Remove"),
//            GenericModel(type: .newPage, name: "Navu")
//        ]
//    }
    
//    func getBlendModeOptions() -> [GenericModel<BlendMode>] {
//        return [
//            GenericModel(type: .normal),
//            GenericModel(type: .multiply, name: "Mul"),
//            GenericModel(type: .darken, name: "DarkSeid")
//        ]
//    }
    
//    func getShadowOptions() -> [GenericModel<ShadowOption>] {
//        return [
//            GenericModel(type: .opacity, name: "par"),
//            GenericModel(type: .radius, name: "Felavo"),
//            GenericModel(type: .width)
//        ]
//    }
    
//    func getAdjustmentOption() -> [GenericModel<ImageFilters>] {
//        return [
//            GenericModel(type: .exposure, name: "Explore"),
//            GenericModel(type: .brightness, name: "Anjvaru"),
//            GenericModel(type: .contrast),
//            GenericModel(type: .vignette, name: "Vighnaharta")
//        ]
//    }
    
//    func getFilePickOptions() -> [GenericModel<FilePickType>] {
//        return [
//            GenericModel(type: .camera, name: "Camero", icon: "ic_template"),
//            GenericModel(type: .file, name: "Folder"),
//            GenericModel(type: .gallery)
//        ]
//    }
    
//    func getLockOptions() -> [GenericModel<LockOptions>] {
//        return [
//            GenericModel(type: .movement, name: "Halvu"),
//            GenericModel(type: .change, name: "Baladvu"),
//            GenericModel(type: .interaction, name: "touch")
//        ]
//    }
    
//    func getRearrangeOptions() -> [GenericModel<RearrangeOption>] {
//        return [
//            GenericModel(type: .left, name: "Dabu"),
//            GenericModel(type: .right, name: "Jamnu"),
//            GenericModel(type: .up, name: "Uper"),
//            GenericModel(type: .down, name: "Niche")
//        ]
//    }
}

