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
    
    @IBAction private func showEditorBtnTapped(_ sender: UIButton) {
        let editor = EditController()
        editor.delegate = self
        editor.startEngine()
        editor.showEditor(from: self.navigationController!)
    }
}

// MARK: Editor delegates
extension ViewController: EditingTools {
    func giveComponentDetails() -> [TemplateEditor.GenericModel<TemplateEditor.ComponentType>] {
        return []
    }
    
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

