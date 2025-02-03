//
//  EditController.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

public class EditController {
    
    static var componentTypes: [GenericModel<ComponentType>] {
        get {
            if let componentTypes = featureDelegate?.giveComponentDetails(), !componentTypes.isEmpty {
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
            if let editOptions = featureDelegate?.giveComponentEditType(), !editOptions.isEmpty {
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
            if let reArrangeOptions = featureDelegate?.getRearrangeOptions(), !reArrangeOptions.isEmpty {
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
            if let lockOptions = featureDelegate?.getLockOptions(), !lockOptions.isEmpty {
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
            if let filePickTypes = featureDelegate?.getFilePickOptions(), !filePickTypes.isEmpty {
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
            if let adjustmentOptions = featureDelegate?.getAdjustmentOption(), !adjustmentOptions.isEmpty  {
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
            if let shadowOptions = featureDelegate?.getShadowOptions(), !shadowOptions.isEmpty {
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
            if let blendOptions = featureDelegate?.getBlendModeOptions(), !blendOptions.isEmpty {
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
            if let pageEdits = featureDelegate?.getPageOptions(), !pageEdits.isEmpty {
                return pageEdits
            } else {
                return AddPageType.allCases.compactMap({ type in
                    return GenericModel(type: type)
                })
            }
        }
    }
    
    public static var featureDelegate: EditingTools?
    public static var userDelegate: UserDetails?
    public static var exportDelegate: ExportDetails?
    public init() { }
    
    public func showEditor(from navigationController: UINavigationController, with data: DynamicUIData? = nil) {
        isUserIsPaid = EditController.userDelegate?.isUserIsPaid() ?? false
        let vc = editorStoryBoard.instantiateViewController(identifier: "EditorViewController") as! EditorViewController
        vc.templateData = data
        vc.userSelectedPremiumFeature = {
            EditController.userDelegate?.userSelectedPremiumOption()
        }
        navigationController.pushViewController(vc, animated: true)
    }
}
