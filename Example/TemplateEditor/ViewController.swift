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
        editor.showEditor(from: self.navigationController!)
    }

}

