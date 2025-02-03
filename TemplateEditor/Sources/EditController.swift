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
    func getFilePickOptions() -> [GenericModel<FilePickType>]
    func getAdjustmentOption() -> [GenericModel<ImageFilters>]
    func getShadowOptions() -> [GenericModel<ShadowOption>]
    func getBlendModeOptions() -> [GenericModel<BlendMode>]
    func getPageOptions() -> [GenericModel<AddPageType>]
}
public protocol UserDetails {
    func userSelectedPremiumOption()
    func isUserIsPaid() -> Bool
}

public extension EditingTools {
    func giveComponentEditType() -> [GenericModel<EditType>] { return [] }
    func getRearrangeOptions() -> [GenericModel<RearrangeOption>] { return [] }
    func getLockOptions() -> [GenericModel<LockOptions>] { return [] }
    func getFilePickOptions() -> [GenericModel<FilePickType>] { return [] }
    func getAdjustmentOption() -> [GenericModel<ImageFilters>] { return [] }
    func getShadowOptions() -> [GenericModel<ShadowOption>] { return [] }
    func getBlendModeOptions() -> [GenericModel<BlendMode>] { return [] }
    func getPageOptions() -> [GenericModel<AddPageType>] { return [] }
}

public class EditController {
    
    static var componentTypes: [GenericModel<ComponentType>] {
        get {
            if let componentTypes = delegate?.giveComponentDetails(), !componentTypes.isEmpty {
                return componentTypes
            } else {
                return ComponentType.allCases.compactMap({ component in
                    return GenericModel(type: component)
                })
            }
        }
    }
    static var editOptions: [GenericModel<EditType>] {
        get {
            if let editOptions = delegate?.giveComponentEditType(), !editOptions.isEmpty {
                return editOptions
            } else {
                return  EditType.allCases.compactMap({ type in
                    return GenericModel(type: type)
                })
            }
        }
    }
    static var rearrangeOptions: [GenericModel<RearrangeOption>] {
        get {
            if let reArrangeOptions = delegate?.getRearrangeOptions(), !reArrangeOptions.isEmpty {
                return reArrangeOptions
            } else {
                return RearrangeOption.allCases.compactMap({ option in
                    return GenericModel(type: option)
                })
            }
        }
    }
    static var lockOptions: [GenericModel<LockOptions>] {
        get {
            if let lockOptions = delegate?.getLockOptions(), !lockOptions.isEmpty {
                return lockOptions
            } else {
                return LockOptions.allCases.compactMap({ option in
                    return GenericModel(type: option)
                })
            }
        }
    }
    static var filePickTypes: [GenericModel<FilePickType>] {
        get {
            if let filePickTypes = delegate?.getFilePickOptions(), !filePickTypes.isEmpty {
                return filePickTypes
            } else {
                return FilePickType.allCases.compactMap({ type in
                    return GenericModel(type: type)
                })
            }
        }
    }
    static var adjustmentOptions: [GenericModel<ImageFilters>] {
        get {
            if let adjustmentOptions = delegate?.getAdjustmentOption(), !adjustmentOptions.isEmpty  {
                return adjustmentOptions
            } else {
                return ImageFilters.allCases.compactMap({ filter in
                    return GenericModel(type: filter)
                })
            }
        }
    }
    static var shadowOptions: [GenericModel<ShadowOption>] {
        get {
            if let shadowOptions = delegate?.getShadowOptions(), !shadowOptions.isEmpty {
                return shadowOptions
            } else {
                return ShadowOption.allCases.compactMap({ option in
                    return GenericModel(type: option)
                })
            }
        }
    }
    static var blendModeOptions: [GenericModel<BlendMode>] {
        get {
            if let blendOptions = delegate?.getBlendModeOptions(), !blendOptions.isEmpty {
                return blendOptions
            } else {
                return BlendMode.allCases.compactMap({ mode in
                    return GenericModel(type: mode)
                })
            }
        }
    }
    static var pageEditType: [GenericModel<AddPageType>] {
        get {
            if let pageEdits = delegate?.getPageOptions(), !pageEdits.isEmpty {
                return pageEdits
            } else {
                return AddPageType.allCases.compactMap({ type in
                    return GenericModel(type: type)
                })
            }
        }
    }
    
    public static var delegate: EditingTools?
    public var userDelegate: UserDetails?
    public init() { }
    
    public func showEditor(from navigationController: UINavigationController, with data: DynamicUIData? = nil) {
        isUserIsPaid = userDelegate?.isUserIsPaid() ?? false
        let vc = editorStoryBoard.instantiateViewController(identifier: "EditorViewController") as! EditorViewController
        vc.templateData = data
        vc.userSelectedPremiumFeature = {
            self.userDelegate?.userSelectedPremiumOption()
        }
        navigationController.pushViewController(vc, animated: true)
    }
}
