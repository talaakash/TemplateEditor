//
//  EditController.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

public class EditController {
    public init() { }
    
    public func showEditor(from navigationController: UINavigationController) {
        let vc = editorStoryBoard.instantiateViewController(identifier: "EditorViewController") as! EditorViewController
        navigationController.pushViewController(vc, animated: true)
        ScreenDetails.bottomSafeArea = vc.view.safeAreaInsets.bottom
    }
}
