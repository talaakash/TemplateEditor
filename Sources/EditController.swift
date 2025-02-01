//
//  EditController.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

public protocol EditingTools {
    func giveComponentDetails() -> [GenericModel<ComponentType>]
    func giveComponentEditType() -> [GenericModel<EditType>]
    func getRearrangeOptions() -> [GenericModel<RearrangeOption>]
    func getLockOptions() -> [GenericModel<LockOptions>]
}
public extension EditingTools {
    func giveComponentEditType() -> [GenericModel<EditType>] { return [] }
    func getRearrangeOptions() -> [GenericModel<RearrangeOption>] { return [] }
    func getLockOptions() -> [GenericModel<LockOptions>] { return [] }
}

public class EditController {
    public var delegate: EditingTools?
    public init() { }
    
    public func startEngine() {
        UserManager.shared.setUserType(type: .paid)
        if let componentsTypes = delegate?.giveComponentDetails(), !componentsTypes.isEmpty {
            ProjectSelectedOptions.componentsTypes = componentsTypes
        }
        if let editOptions = delegate?.giveComponentEditType(), !editOptions.isEmpty {
            ProjectSelectedOptions.editOptions = editOptions
        }
        if let reArrangeOptions = delegate?.getRearrangeOptions(), !reArrangeOptions.isEmpty {
            ProjectSelectedOptions.rearrangeOptions = reArrangeOptions
        }
        if let lockOptions = delegate?.getLockOptions(), !lockOptions.isEmpty {
            ProjectSelectedOptions.lockOptions = lockOptions
        }
    }
    
    public func showEditor(from navigationController: UINavigationController) {
        let vc = editorStoryBoard.instantiateViewController(identifier: "EditorViewController") as! EditorViewController
        navigationController.pushViewController(vc, animated: true)
    }
}
