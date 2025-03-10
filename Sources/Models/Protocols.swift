//
//  Protocols.swift
//  Pods
//
//  Created by Akash Tala on 03/02/25.
//

// MARK: - Protocol for editing tools change
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
    func getResizeOptions() -> [GenericModel<ResizeOption>]
    func getMenuSpacingOptions() -> [GenericModel<Spacing>]
}

// MARK: - Protocol for identify user selection and usertype
public protocol UserDetails {
    func userSelectedPremiumOption()
    func isUserIsPaid() -> Bool
}

// MARK: -
public protocol ExportDetails {
    func getSaveOption(completion: @escaping (ExportOption, SaveContentSize) -> Void)
    func exportedImages(images: [UIImage])
    func exportedJson(json: [String: Any])
    func forQrCodeGeneration(json: [String : Any], pdfData: Data)
    func somethingWentWrong()
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
    func getResizeOptions() -> [GenericModel<ResizeOption>] { return [] }
    func getMenuSpacingOptions() -> [GenericModel<Spacing>] { return [] }
}
