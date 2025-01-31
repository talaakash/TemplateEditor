import UIKit
import Photos

class EditorViewController: UIViewController {

    @IBOutlet private weak var pageCollection: UICollectionView!
    @IBOutlet private weak var componentCollection: UICollectionView!
    @IBOutlet private weak var pageControl: UIPageControl!
    @IBOutlet private weak var undoBtn: UIControl!
    @IBOutlet private weak var redoBtn: UIControl!
    @IBOutlet private weak var exportBtn: UIControl!
    @IBOutlet private weak var adderBottomAnchor: NSLayoutConstraint!
    @IBOutlet private weak var undoRedoBtnTrailingAnchor: NSLayoutConstraint!
    @IBOutlet private weak var componentCollectionHeightAnchor: NSLayoutConstraint!
    
    private var alertController: AlertController?
    private var isNeedToStartFromScratch: Bool = false
    private var isDataLoaded: Bool = false
    private var editOptionView: EditOptionView!
    private var viewModel = EditorViewModel()
    private var componentTypes: [ComponentType] = ComponentType.allCases
    private var bgImage: UIImage?
    private var widthSize: CGFloat = 0
    private var heightSize: CGFloat = 0
    private var currentPage: UIView? {
        if let cell = self.pageCollection.visibleCells.first as? CanvasCell {
            return cell.mainView
        } else if let indexPath = self.pageCollection.indexPathsForSelectedItems?.first, let cell = self.pageCollection.cellForItem(at: indexPath) as? CanvasCell {
            return cell.mainView
        } else {
            let cell = self.pageCollection.visibleCells.last as? CanvasCell
            return cell?.mainView
        }
    }
    private var pageCount: Int = 1 {
        didSet {
            self.pageControl.numberOfPages = pageCount
            if pageCount > 1 {
                self.pageControl.isHidden = false
            }
        }
    }
    private var currentPageIndex: Int = 0 {
        didSet {
            self.pageControl.currentPage = currentPageIndex
        }
    }
    private var uniqueIdentifierIds: [Int: Int] = [:]
    private var deletedIdentifierId: [Int] = []
    private var deletedIdentifierValue: [Int] = []
    var templateData: DynamicUIData?
    var projectId: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doInitSetup()
    }
    
    private func doInitSetup() {
        if isIpad {
            self.componentCollectionHeightAnchor.constant *= 1.5
        }
        self.adderBottomAnchor.constant = self.adderBottomAnchor.constant + ScreenDetails.bottomSafeArea
        
        self.componentCollection.registerNib(for: OptionCell.self)
        
        self.pageControl.isHidden = true
        self.currentPageIndex = 1
        
        if !isUserIsAdmin {
            self.undoRedoBtnTrailingAnchor.constant = -self.exportBtn.frame.width
            self.exportBtn.isHidden = true
        }
        
        if templateData == nil {
            self.isNeedToStartFromScratch = true
        }
        
        self.viewModel.delegate = self
        self.viewModel.setupController()
        self.viewModel.componentCollection = self.componentCollection
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let editOption = editOptionView {
            editOption.editOptionCollection.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isDataLoaded {
            if self.isNeedToStartFromScratch {
                self.presentImagePicker(sourceType: .photoLibrary, for: .bg)
                self.isNeedToStartFromScratch = false
            } else {
                self.loadTemplateData()
            }
            isDataLoaded = true
        }
        self.checkForUndoRedoAvailability()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let touchLocation = touch.location(in: self.view)
        if let touchedView = self.view.hitTest(touchLocation, with: event) {
            if touchedView.restorationIdentifier == "dragHandle" { return }
        }
        
        guard viewModel.openedView == nil else { return }
        self.view.endEditing(true)
        viewModel.openedView?.remove(complete: {
            self.viewModel.openedView = nil
        })
        viewModel.selectedView = nil
    }
}

// MARK: - Action Methods
extension EditorViewController {
    @IBAction private func undoBtnTapped(_ sender: UIControl) {
        UndoRedoManager.shared.undo()
        self.checkForUndoRedoAvailability()
        self.viewModel.undoRedoHappen()
    }
    
    @IBAction private func redoBtnTapped(_ sender: UIControl) {
        UndoRedoManager.shared.redo()
        self.checkForUndoRedoAvailability()
        self.viewModel.undoRedoHappen()
    }
    
    @IBAction private func exportBtnTapped(_ sender: UIControl) {
        self.viewModel.selectedView = nil
        if let json = getJsonData() {
            let alertController = UIAlertController(title: "Dynamic Elements", message: "Do you wanna store it permanently?", preferredStyle: .actionSheet)
            let yes = UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
                ProgressView.shared.showProgress()
                var jsonName = String(Int(Date().timeIntervalSince1970))
                if let projectId = self?.projectId {
                    jsonName = projectId
                }
                self?.storeJsonPermanently(with: jsonName,json: json, success: { [weak self] in
                    ProgressView.shared.hideProgress()
                    let successAlert = UIAlertController(title: "appName".localize(), message: "Json Saved with Name:\n\(jsonName)", preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: "Okay", style: .default))
                    self?.present(successAlert, animated: true)
                }, failure: { error in
                    ProgressView.shared.hideProgress()
                    debugPrint(error)
                })
            })
            let no = UIAlertAction(title: "No store locally", style: .cancel, handler: { _ in
                let jsonName = String(Int(Date().timeIntervalSince1970))
                if let _ = StorageManager.shared.storeJson(with: jsonName, json: json, in: .json) {
                    var jsonNames = UserDefaults.standard.value(forKey: UserDefaultsKeys.storedJsonNames) as? [String]
                    let newName = "\(Folders.json.rawValue)/\(jsonName)"
                    if jsonNames != nil {
                        jsonNames?.append(newName)
                    } else {
                        jsonNames = [newName]
                    }
                    UserDefaults.standard.setValue(jsonNames, forKey: UserDefaultsKeys.storedJsonNames)
                }
            })
            alertController.addAction(yes)
            alertController.addAction(no)
            self.present(alertController, animated: true)
        }
    }
    
    @IBAction private func saveBtnTapped(_ sender: UIControl) {
        let vc = self.storyboard?.instantiateViewController(identifier: ViewControllers.exportOptionsStoryBoardID) as! ExportOptions
        vc.modalPresentationStyle = .overCurrentContext
        vc.exportOption = { [weak self] option in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch option {
                case .qr:
                    guard UserManager.shared.isUserLoggedIn else { self.showLoginAlert(); return }
                    guard UserManager.shared.currentUserType == .paid else { self.showPremiumFeatureAlert(); return }
                    self.generateQrCode()
                case .pdf:
                    let images = self.getImagesFromTemplate(with: .HD, contentSize: .medium)
                    if let url = StorageManager.shared.generatePdf(from: images) {
                        ProgressView.shared.hideProgress()
                        let documentPicker = UIDocumentPickerViewController(forExporting: [url])
                        documentPicker.delegate = self
                        self.present(documentPicker, animated: true)
                    } else {
                        ProgressView.shared.hideProgress()
                    }
                case .images:
                    self.saveImagesInGallery()
                }
            }
        }
        self.navigationController?.present(vc, animated: false)
    }
    
    @IBAction func backBtnTapped(_ sender: UIControl) {
        guard UndoRedoManager.shared.canUndo else {
            UndoRedoManager.shared.clearUndoRedoStack()
            self.navigationController?.popViewController(animated: true)
            return
        }
        UndoRedoManager.shared.clearUndoRedoStack()
        self.alertController = AlertController(message: "editCloseMessage".localize())
        self.alertController?.setBtn(title: "saveBtnTitle".localize(), handler: { [weak self] in
            if let json = self?.getJsonData() {
                let jsonName = String(Int(Date().timeIntervalSince1970))
                if let _ = StorageManager.shared.storeJson(with: jsonName, json: json, in: .json) {
                    var jsonNames = UserDefaults.standard.value(forKey: UserDefaultsKeys.storedJsonNames) as? [String]
                    let newName = "\(Folders.json.rawValue)/\(jsonName)"
                    if jsonNames != nil {
                        jsonNames?.append(newName)
                    } else {
                        jsonNames = [newName]
                    }
                    UserDefaults.standard.setValue(jsonNames, forKey: UserDefaultsKeys.storedJsonNames)
                    UndoRedoManager.shared.clearUndoRedoStack()
                    self?.navigationController?.popViewController(animated: true)
                }
            }
        })
        self.alertController?.setBtn(title: "cancelBtnTitle".localize(), handler: { [weak self] in
            UndoRedoManager.shared.clearUndoRedoStack()
            self?.navigationController?.popViewController(animated: true)
        })
        self.alertController?.showAlertBox()
    }
    
    @IBAction private func pageControlValueChanged(_ sender: UIPageControl) {
        self.pageCollection.selectItem(at: IndexPath(item: sender.currentPage, section: 0), animated: true, scrollPosition: .centeredHorizontally)
    }
    
    @objc func addImageToLayerBtnTapped(_ sender: UIButton) {
        if let draggableView = sender.superview as? DraggableUIView {
            viewModel.selectedView = draggableView
            presentImagePicker(sourceType: .photoLibrary, for: .changing)
            DispatchQueue.main.async {
                sender.removeFromSuperview()
            }
        }
    }
}

// MARK: - Private methods
extension EditorViewController {
    private func showLoginAlert() {
        
    }
    
    private func makeSubviewsBlink(view: UIView, times: Int, duration: TimeInterval) {
        guard times > 0 else { return }
        let views = view.subviews.filter({ $0.isUserInteractionEnabled })
        UIView.animate(withDuration: duration, animations: {
            views.forEach { $0.alpha = 0.3 }
        }) { _ in
            UIView.animate(withDuration: duration, animations: {
                views.forEach { $0.alpha = 1 }
            }) { _ in
                self.makeSubviewsBlink(view: view, times: times - 1, duration: duration)
            }
        }
    }

    private func showPremiumFeatureAlert() {
        self.alertController = AlertController(message: "premiumPurchaseMessage".localize())
        self.alertController?.setBtn(title: "continueBtnTitle".localize(), handler: { [weak self] in
            
        })
        self.alertController?.setBtn(title: "cancelBtnTitle".localize(), handler: { })
        self.alertController?.showAlertBox()
    }

    private func checkForUndoRedoAvailability() {
        if UndoRedoManager.shared.canUndo {
            self.undoBtn.alpha = 1
            self.undoBtn.isUserInteractionEnabled = true
        } else {
            self.undoBtn.alpha = 0.5
            self.undoBtn.isUserInteractionEnabled = false
        }
        
        if UndoRedoManager.shared.canRedo {
            self.redoBtn.alpha = 1
            self.redoBtn.isUserInteractionEnabled = true
        } else {
            self.redoBtn.alpha = 0.5
            self.redoBtn.isUserInteractionEnabled = false
        }
    }
    
    private func loadTemplateData() {
        if let templateData {
            self.viewModel.dynamicUIData = templateData
            self.viewModel.configureMainViewSize(
                view: self.pageCollection,
                viewHeight: &self.heightSize,
                viewWidth: &self.widthSize
            )
            self.pageCollection.reloadData()
            DispatchQueue.main.async {
                self.configureUI(with: templateData)
            }
        }
    }
    
    private func configureUI(with data: DynamicUIData) {
        ProgressView.shared.showProgress()
        func addPage(at index: Int, totalPages: Int) {
            self.pageCollection.performBatchUpdates({
                self.pageCount += 1
                self.pageCollection.insertItems(at: [IndexPath(item: index, section: 0)])
            }, completion: { _ in
                if index < totalPages - 1 {
                    addPage(at: (index + 1), totalPages: totalPages)
                } else {
                    self.addComponentsInView(pageIndex: 0, elements: data.elements, superViewWidth: data.superViewWidth, superViewHeight: data.superViewHeight)
                }
            })
        }
        
        if data.elements.count > 1 {
            addPage(at: 1, totalPages: data.elements.count)
        } else {
            self.addComponentsInView(pageIndex: 0, elements: data.elements, superViewWidth: data.superViewWidth, superViewHeight: data.superViewHeight)
        }
    }
    
    private func addComponentsInView(pageIndex: Int, elements: [String: [UIElement]], superViewWidth: CGFloat, superViewHeight: CGFloat) {
        let scaleX = self.widthSize / superViewWidth
        let scaleY = self.heightSize / superViewHeight
        
        self.pageCollection.performBatchUpdates({
            self.pageCollection.selectItem(at: IndexPath(item: pageIndex, section: 0), animated: false, scrollPosition: .centeredVertically)
        }, completion: { _ in
            for element in elements["\(pageIndex)"] ?? [] {
                switch element.type {
                case ComponentType.label.rawValue:
                    if let fontURL = element.fontURL {
                        self.downloadAndApplyFont(from: fontURL) { fontName in
                            guard let fontName else { return }
                            if let font = UIFont(name: fontName, size: (element.size ?? 18) * min(scaleX, scaleY)) {
                                let _ = self.createLabel(with: element, fontFamily: font, scaleX: scaleX, scaleY: scaleY)
                            } else {
                                let font = UIFont.systemFont(ofSize: CGFloat(element.size ?? 18) * min(scaleX, scaleY))
                                let _ = self.createLabel(with: element, fontFamily: font, scaleX: scaleX, scaleY: scaleY)
                            }
                        }
                    } else {
                        let font = UIFont.systemFont(ofSize: CGFloat(element.size ?? 18) * min(scaleX, scaleY))
                        let _ = self.createLabel(with: element, fontFamily: font, scaleX: scaleX, scaleY: scaleY)
                    }
                case ComponentType.image.rawValue:
                    self.createImageView(with: element, scaleX: scaleX, scaleY: scaleY)
                case ComponentType.menuBox.rawValue:
                    self.createMenuView(with: element, scaleX: scaleX, scaleY: scaleY)
                case ComponentType.shape.rawValue:
                    self.createShapeView(with: element, scaleX: scaleX, scaleY: scaleY)
                default:
                    break
                }
            }
            if pageIndex < elements.count - 1 {
                self.addComponentsInView(pageIndex: (pageIndex + 1), elements: elements, superViewWidth: superViewWidth, superViewHeight: superViewHeight)
            } else {
                self.pageCollection.performBatchUpdates({
                    self.pageCollection.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .centeredVertically)
                }, completion: { _ in
                    if let page = self.currentPage {
                        self.makeSubviewsBlink(view: page, times: 2, duration: 0.33)
                    }
                })
                ProgressView.shared.hideProgress()
            }
        })
    }
    
    private func downloadAndApplyFont(from urlStringOrFontName: String, completion: @escaping (String?) -> Void) {
        // Check if the string is a valid URL
        if let url = URL(string: urlStringOrFontName), UIApplication.shared.canOpenURL(url) {
            // It's a URL, proceed to download and apply the font
            viewModel.downloadFont(from: url, completion: completion)
        } else {
            // It's not a URL, assume it's a font name and check locally
            let fontName = urlStringOrFontName
            
            // Check if the font exists locally
            if UIFont(name: fontName, size: 12) != nil {
                // Font exists, return the font name
                completion(fontName)
            } else {
                // Font does not exist locally
                completion(nil)
            }
        }
    }
    
    private func extractWhiteAreas(from image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        // Create a raw buffer to store pixel data
        var rawData = [UInt8](repeating: 0, count: height * bytesPerRow)
        
        // Create context for pixel manipulation
        guard let context = CGContext(data: &rawData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        // Draw the image into the context to extract the pixel data
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        
        // Loop through each pixel and modify alpha if the pixel is white
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * bytesPerRow) + (x * bytesPerPixel)
                
                let red = rawData[pixelIndex]
                let green = rawData[pixelIndex + 1]
                let blue = rawData[pixelIndex + 2]
                
                // Check if the pixel is white (with some tolerance)
                if red > 240 && green > 240 && blue > 240 {
                    // Keep this pixel fully opaque
                    rawData[pixelIndex + 3] = 255 // Set alpha to 1
                } else {
                    // Make this pixel fully transparent
                    rawData[pixelIndex + 3] = 0 // Set alpha to 0
                }
            }
        }
        
        // Create a new image from the modified pixel data
        guard let newCgImage = context.makeImage() else { return nil }
        
        return UIImage(cgImage: newCgImage)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType, for task: TaskType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.view.tag = task.value
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func getBGElement(height: CGFloat, width: CGFloat, scaleX: CGFloat, scaleY: CGFloat) -> UIElement {
        return UIElement(
            type: ComponentType.image.rawValue,
            x: -12,
            y: -12,
            width: width + 24,
            height: height + 24,
            movable: false,
            isUserInteractionEnabled: false,
            alpha: 1,
            isDuplicatable: false,
            isRemovable: false,
            cornerRadius: 0,
            backGroundColor: "#FFFFFF",
            rotationAngle: 0,
            text: nil,
            alignment: nil,
            textColor: nil,
            fontURL: nil,
            size: nil,
            isEditable: nil,
            contentMode: 1,
            url: "https://example.com/sample-image.png",
            itemNameFontSize: nil, itemDescriptionFontSize: nil, itemValueFontSize: nil, columnWidth: nil, columnSpace: 0, menuData: nil
        )
    }
    
    private func getImageRect(imageSize: CGSize, viewSize: CGSize) -> CGRect{
        let imageAspectRatio = imageSize.width / imageSize.height
        let imageViewAspectRatio = viewSize.width / viewSize.height
        
        var drawRect = CGRect.zero
        
        if imageAspectRatio > imageViewAspectRatio {
            // Image is wider than the view
            let width = viewSize.width
            let height = width / imageAspectRatio
            let yOffset = (viewSize.height - height) / 2
            drawRect = CGRect(x: 0, y: yOffset, width: width, height: height)
        } else {
            // Image is taller than the view
            let height = viewSize.height
            let width = height * imageAspectRatio
            let xOffset = (viewSize.width - width) / 2
            drawRect = CGRect(x: xOffset, y: 0, width: width, height: height)
        }
        
        if drawRect.width > viewSize.width{
            drawRect.size.width = viewSize.width
        }
        if drawRect.height > viewSize.height{
            drawRect.size.height = viewSize.height
        }
        
        return drawRect
    }
    
    private func getBGImageFromRecent() -> UIImage? {
        guard let cell = self.pageCollection.cellForItem(at: IndexPath(item: 0, section: 0 )) as? CanvasCell else { return nil }
        
        for subView in cell.mainView.subviews {
            if let draggableView = subView as? DraggableUIView {
                if let imgView = draggableView.subviews.compactMap({ $0 as? UIImageView }).first {
                    if draggableView.frame.width >= self.widthSize && draggableView.frame.height >= self.heightSize {
                        return imgView.image
                    }
                }
            }
        }
        
        return nil
    }
    
    private func getMenuColorFromData() -> (String?, String?, String?)? {
        for (_, value) in self.templateData?.elements ?? [:]{
            for component in value {
                if let componentType = ComponentType(rawValue: component.type), componentType == .menuBox {
                    return (component.itemNameTextColor, component.itemDescriptionTextColor, component.itemValueTextColor)
                }
            }
        }
        return nil
    }
    
    private func loadEditOption() {
        if editOptionView != nil && !viewModel.editOptions.isEmpty {
            editOptionView.editOptions = viewModel.editOptions
            editOptionView?.editOptionCollection.reloadData()
            return
        } else if self.viewModel.selectedView == nil && editOptionView != nil {
            editOptionView.remove(complete: {
                self.editOptionView = nil
            })
            return
        } else if self.viewModel.selectedView == nil {
            return
        }
        
        editOptionView = UINib(nibName: "EditOptionView", bundle: packageBundle).instantiate(withOwner: nil).first as? EditOptionView
        editOptionView.editOptions = viewModel.editOptions
        editOptionView.isRemoved = { [weak self] in
            self?.viewModel.selectedView = nil
            self?.editOptionView.remove(complete: {
                self?.editOptionView = nil
            })
        }
        editOptionView.selectedOption = { [weak self] option in
            DispatchQueue.main.async {
                self?.selectedOption(option)
            }
        }
        self.view.addSubview(editOptionView)
        self.viewModel.editOptionView = editOptionView
        editOptionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            editOptionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            editOptionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            editOptionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        editOptionView.editOptionCollection.reloadData()
    }
    
    private func selectedOption(_ option: EditType) {
        if option.isPremiumFeature && UserManager.shared.currentUserType == .free {
            self.showPremiumFeatureAlert()
            return
        }
        
        guard let selectedView = viewModel.selectedView else { return }
        
        switch option {
        case .delete:
            self.deleteElement()
        case .copy:
            self.duplicateElement(selectedView)
        case .move:
            self.presentObjectMover()
        case .backgroundColor:
            self.presentColorPicker(for: .backgroundColor, selectedColor: selectedView.backgroundColor ?? .clear)
        case .lock:
            self.presentLockOptionView()
        default:
            break
        }
        
        if let label = selectedView.subviews.compactMap({ $0 as? UITextView }).first {
            switch option {
            case .fontChange:
                self.createFontPicker(for: label)
            case .editFont:
                self.presentTextInput()
            case .fontSize:
                self.presentFontSizeAdjuster()
            case .fontColor:
                self.presentColorPicker(for: .textColor, selectedColor: label.textColor ?? .black)
            default:
                break
            }
        }
        
        if let menuBox = selectedView.subviews.compactMap({ $0 as? GridView }).first {
            switch option {
            case .editContent:
                var fontSize: [String: CGFloat] = [:]
                fontSize["itemNameFontSize"] = menuBox.itemNameFontSize
                fontSize["itemDescriptionFontSize"] = menuBox.itemDescriptionFontSize
                fontSize["itemValueFontSize"] = menuBox.itemValueFontSize
                let vc = self.storyboard?.instantiateViewController(withIdentifier: ViewControllers.menuEditorVCStoryBoardID) as! MenuEditorVC
                vc.menuStyle = menuBox.menuStyle
                vc.menuData = menuBox.data
                vc.updatedData = { [weak self] newData in
                    self?.setNewData(in: menuBox, newData: newData, newFrame: selectedView.frame)
                    menuBox.itemNameFontSize = fontSize["itemNameFontSize"] ?? menuBox.itemNameFontSize
                    menuBox.itemDescriptionFontSize = fontSize["itemDescriptionFontSize"] ?? menuBox.itemDescriptionFontSize
                    menuBox.itemValueFontSize = fontSize["itemValueFontSize"] ?? menuBox.itemValueFontSize
                }
                self.navigationController?.pushViewController(vc, animated: true)
            case .changeSize:
                self.presentMenuFontSizeView()
            case .adjustSpace:
                self.presentMenuSpacingAdjustView()
            default:
                break
            }
        }
        
        guard let componentName = selectedView.componentType, let componentType = ComponentType(rawValue: componentName) else { return }
        
        if let img = selectedView.subviews.compactMap({ $0 as? UIImageView }).first {
            if selectedView.originalImage == nil {
                selectedView.originalImage = img.image
            }
            switch option { // Common both in Image and Shape
            case .flipH:
                if componentType == .shape {
                    self.setNewImage(newImg: selectedView.originalImage?.flippedHorizontally()?.withRenderingMode(.alwaysTemplate), in: selectedView)
                } else {
                    self.setNewImage(newImg: selectedView.originalImage?.flippedHorizontally(), in: selectedView)
                }
            case .flipV:
                if componentType == .shape {
                    self.setNewImage(newImg: selectedView.originalImage?.flippedVertically()?.withRenderingMode(.alwaysTemplate), in: selectedView)
                } else {
                    self.setNewImage(newImg: selectedView.originalImage?.flippedVertically(), in: selectedView)
                }
            case .crop:
                if let originalImage = selectedView.originalImage {
                    let cropperVC = CropperViewController(originalImage: originalImage)
                    cropperVC.view.tag = TaskType.changing.value
                    cropperVC.delegate = self
                    self.present(cropperVC, animated: true)
                }
            case .blur:
                self.presentImageEffectView(with: .blur)
            case .opacity:
                self.presentImageEffectView(with: .opacity)
            case .shadow:
                self.presentShadowEffectView()
            case .blendImage:
                self.presentBlendModeView()
                break
            default:
                break
            }
            
            switch componentType {
            case .image:
                switch option {
                case .change:
                    self.presentImagePickerOptions(for: true)
                case .layered:
                    selectedView.isLayered = true
//                    self.addLayeredImage(in: selectedView)  // if needed then admin can also see this
                case .adjustments:
                    self.presentAdjustmentView()
                default:
                    break
                }
            case .shape:
                switch option {
                case .tintColor:
                    self.presentColorPicker(for: .tintColor, selectedColor: img.tintColor)
                case .change:
                    self.presentShapeView(forAdding: false)
                default:
                    break
                }
            default:
                break
            }
        }
    }
    
    private func saveImagesInGallery() {
        let vc = self.storyboard?.instantiateViewController(identifier: ViewControllers.imageQualityInputControllerStoryBoardID) as! ImageQualityInputController
        vc.modalPresentationStyle = .overCurrentContext
        vc.selectedQuality = { [weak self] quality in
            switch quality {
            case .SD:
                self?.saveViewAsImageToPhotoLibrary(resolution: .SD)
            case .HD:
                self?.saveViewAsImageToPhotoLibrary(resolution: .HD)
            }
        }
        self.present(vc, animated: false)
    }
    
    private func generateQrCode() {
        guard let userId = UserManager.shared.currentUserId else { return }
        ProgressView.shared.showProgress()
        self.viewModel.selectedView = nil
        if let json = getJsonData() {
            let projectUniqueName = String(Int(Date().timeIntervalSince1970))
            self.storeJsonPermanently(with: projectUniqueName,json: json, success: { }, failure: { error in
                debugPrint(error)
                ProgressView.shared.hideProgress()
            }, getDocumentData: { [weak self] documentData in
                self?.getPdfQrCode(success: { qrDetails in
                    var templateData = documentData
                    templateData.merge(qrDetails) { (_, new) in new }
//                    FirestoreManager.shared.setSubDocument(in: .userDetails, subCollection: .userCreation, key: userId, data: templateData, success: {
//                        ProgressView.shared.hideProgress()
//                        debugPrint("Document saved successfully")
//                    }, failure: { _ in
//                        ProgressView.shared.hideProgress()
//                    })
                }, failure: { error in
                    ProgressView.shared.hideProgress()
                })
            })
        }
    }
    
    private func getPdfQrCode(with img: UIImage = UIImage(), success: @escaping ([String: Any]) -> Void, failure: @escaping (String) -> Void) {
        let images = self.getImagesFromTemplate(with: .HD, contentSize: .normal)
        if let pdfData = UtilsManager.shared.generateAndGetPdfData(using: images) {
//            FirebaseStorageManager.shared.storeData(type: .pdfs, data: pdfData, success: { downloadUrl in
//                if let img = downloadUrl.qrImage(withLogo: img) {
//                    FirebaseStorageManager.shared.storeData(type: .qrCodes, image: img, success: { qrUrl in
//                        let data = ["pdfUrl": downloadUrl.absoluteString, "qrUrl": qrUrl.absoluteString]
//                        success(data)
//                    }, failure: { error in
//                        failure(error)
//                    })
//                } else {
//                    failure("somethingWentWrong".localize())
//                }
//            }, failure: { error in
//                failure(error)
//            })
        } else {
            failure("somethingWentWrong".localize())
        }
    }
}

// MARK: - ViewModel Delegate
extension EditorViewController: EditorViewModelDelegate {
    func deleteViewBtnTapped(view: UIView) {
        self.removeView(view)
    }
    
    func adjustLayerOptionSelected(adjustBtn: UIView) {
        guard let selectedView = self.viewModel.selectedView, let currentIndex = currentPage?.subviews.firstIndex(of: selectedView) else { return }
        let totalSubViews = (currentPage?.subviews.count ?? 0) - 1
        CM.items = [ContextMenuItemWithImage(title: "Bring Forward", image: UIImage(named: "layerBringFront")!, isEnabled: (currentIndex + 1) < totalSubViews), ContextMenuItemWithImage(title: "Send Backward", image: UIImage(named: "layerSendBack")!, isEnabled: (currentIndex - 1) > 0)]
        CM.showMenu(viewTargeted: adjustBtn, delegate: self, animated: true)
    }
    
    func checkUndoRedoAvailable() {
        self.checkForUndoRedoAvailability()
    }
    
    func willUpdateSelectedView(_ selectedView: DraggableUIView?) {
        guard viewModel.selectedView != nil else { return }
    }
    
    func didUpdateSelectedView(_ selectedView: DraggableUIView?) {
        view.endEditing(true)
        self.loadEditOption()
    }
}

// MARK: - ContextMenu Delegate
extension EditorViewController: ContextMenuDelegate {
    func contextMenuDidSelect(forRowAt index: Int) -> Bool {
        self.viewModel.controllerView.removeFromSuperview()
        guard let selectedView = self.viewModel.selectedView else { return true }
        guard let currentIndex = currentPage?.subviews.firstIndex(of: selectedView) else {
            return true
        }
        switch index {
        case 0:
            let newIndex = currentIndex + 1
            if newIndex >= currentPage?.subviews.count ?? 0 { self.viewModel.selectedView = selectedView; return false }
            if let currentPage {
                self.insertSubViewAt(position: newIndex, view: selectedView, parentView: currentPage)
            }
            DispatchQueue.main.async {
                self.viewModel.selectedView = selectedView
            }
        case 1:
            let newIndex = currentIndex - 1
            if newIndex < 1 { self.viewModel.selectedView = selectedView; return false }
            if let currentPage {
                self.insertSubViewAt(position: newIndex, view: selectedView, parentView: currentPage)
            }
            DispatchQueue.main.async {
                self.viewModel.selectedView = selectedView
            }
        default:
            break
        }
        return true
    }
    
    func contextMenuDidDeselect(forRowAt index: Int) {
        
    }
}

// MARK: - Component Edit Helper Method
extension EditorViewController {
    private func presentColorPicker(for option: ColorType, selectedColor: UIColor, menuField: ResizeOption = .itemName) {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        colorPicker.supportsAlpha = true
        colorPicker.selectedColor = selectedColor
        colorPicker.view.tag = option.rawValue
        colorPicker.view.stringTag = "\(menuField.rawValue)"
        colorPicker.modalPresentationStyle = .popover
        if isIpad {
            if let popoverPresentationController = colorPicker.popoverPresentationController {
                popoverPresentationController.sourceView = self.view
                popoverPresentationController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popoverPresentationController.permittedArrowDirections = []
            }
        }
        self.present(colorPicker, animated: true, completion: nil)
    }
    
    private func presentFilePicker(for task: TaskType = .adding) {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.image])
        documentPicker.delegate = self
        documentPicker.view.tag = task.value
        documentPicker.allowsMultipleSelection = false
        documentPicker.modalPresentationStyle = .fullScreen
        self.present(documentPicker, animated: true)
    }
    
    private func presentImagePickerOptions(for change: Bool = false) {
        var imagePickerView = UINib(nibName: "ChoseImageView", bundle: packageBundle).instantiate(withOwner: nil).first as? ChoseImageView
        imagePickerView?.actionHappen = { [weak self] _ in
            self?.viewModel.openedView = nil
            imagePickerView?.remove(complete: {
                imagePickerView = nil
            })
        }
        imagePickerView?.selectedOption = { [weak self] option in
            switch option {
            case .gallery:
                self?.presentImagePicker(sourceType: .photoLibrary, for: change ? .changing : .adding)
            case .file:
                self?.presentFilePicker(for: change ? .changing : .adding)
            case .camera:
                self?.presentImagePicker(sourceType: .camera, for: change ? .changing : .adding)
            }
        }
        
        if let imagePickerView {
            viewModel.openedView = imagePickerView
            self.view.addSubview(imagePickerView)
            imagePickerView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imagePickerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                imagePickerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                imagePickerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    private func presentAddPageOptions() {
        var addPageView = UINib(nibName: "AddPageView", bundle: packageBundle).instantiate(withOwner: nil).first as? AddPageView
        addPageView?.actionHappen = {
            self.viewModel.openedView = nil
            addPageView?.removeFromSuperview()
            addPageView = nil
        }
        addPageView?.selectedOption = { option in
            self.viewModel.openedView = nil
            addPageView?.removeFromSuperview()
            addPageView = nil
            switch option {
            case .newPage:
                self.addPageView(at: self.pageCount)
            case .copyPage:
                self.copyPageView(at: self.pageCount)
            case .deletePage:
                self.removePageView(at: self.currentPageIndex)
            }
        }
        
        if let addPageView {
            viewModel.openedView = addPageView
            self.view.addSubview(addPageView)
            addPageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                addPageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                addPageView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                addPageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    private func createFontPicker(for lbl: UITextView) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "FontPickerController") as! FontPickerController
        vc.selectedFontDescriptor = { [weak self] descriptor in
            let selectedFont = UIFont(name: descriptor, size: lbl.font?.pointSize ?? 17)
            self?.setFont(for: lbl, to: selectedFont)
            self?.adjustTextHeight(txtView: lbl, view: self?.viewModel.selectedView ?? UIView())
        }
        self.present(vc, animated: true)
    }
    
    private func presentTextInput() {
        guard let selectedView = self.viewModel.selectedView, let label = selectedView.subviews.compactMap({ $0 as? UITextView}).first else { return }
        let originalText = label.text
        let originalFontSize = label.font?.pointSize
        let oldSize = self.viewModel.selectedView?.frame
        var textEditView = UINib(nibName: "TextEditView", bundle: packageBundle).instantiate(withOwner: nil).first as? TextEditView
        textEditView?.currentText = label.text
        textEditView?.actionHappen = { [weak self] actionType in
            self?.viewModel.openedView = nil
            textEditView?.remove(complete: {
                textEditView = nil
            })
            switch actionType {
            case .close:
                label.text = originalText
                label.font = label.font?.withSize(originalFontSize ?? 18)
                if let oldSize {
                    selectedView.frame = oldSize
                }
            case .check:
                let newText = label.text
                let newFontSize = label.font?.pointSize
                let newFrame = selectedView.frame
                label.text = originalText
                label.font = label.font?.withSize(originalFontSize ?? 18)
                if let oldSize {
                    selectedView.frame = oldSize
                }
                self?.changeTextOfLabel(label: label, newText: newText, newSize: newFontSize, newFrame: newFrame)
            }
        }
        textEditView?.changedText = { [weak self] newText in
            label.text = newText
            self?.adjustTextHeight(txtView: label, view: selectedView)
        }
        
        if let textEditView {
            viewModel.openedView = textEditView
            self.view.addSubview(textEditView)
            textEditView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                textEditView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                textEditView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                textEditView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    private func presentFontSizeAdjuster() {
        guard let selectedView = viewModel.selectedView, let textView = selectedView.subviews.compactMap({ $0 as? UITextView }).first else { return }
        
        let originalValue: CGFloat = textView.font?.pointSize ?? 17
        let originalFrame = selectedView.frame
        var effectView = UINib(nibName: "ImageEffectView", bundle: packageBundle).instantiate(withOwner: nil).first as? ImageEffectView
        effectView?.effectType = .fontSize
        effectView?.currentAdjustValue = originalValue
        effectView?.intensityChanged = { [weak self] intensity in
            textView.font = textView.font?.withSize(intensity * 100)
            self?.adjustTextHeight(txtView: textView, view: selectedView)
        }
        effectView?.actionHappen = { [weak self] action in
            effectView?.remove(complete: {
                effectView = nil
            })
            self?.viewModel.openedView = nil
            switch action {
            case .close:
                textView.font = textView.font?.withSize(originalValue)
                selectedView.frame = originalFrame
            case .check:
                let newFontSize = textView.font?.pointSize ?? originalValue
                let newFrame = selectedView.frame
                selectedView.frame = originalFrame
                textView.font = textView.font?.withSize(originalValue)
                self?.changeTextOfLabel(label: textView, newText: textView.text, newSize: newFontSize, newFrame: newFrame)
            }
        }
        if let effectView {
            viewModel.openedView = effectView
            self.view.addSubview(effectView)
            effectView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                effectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                effectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                effectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    private func presentObjectMover() {
        guard let selectedView = viewModel.selectedView else { return }
        
        var moverView = UINib(nibName: "MoveObjectView", bundle: packageBundle).instantiate(withOwner: nil).first as? MoveObjectView
        
        // We can modify this intensity to slow or fast move
        let intensity: CGFloat = 2
        let originalState = selectedView.captureCurrentState()
        
        moverView?.actionHappen = { [weak self] option in
            self?.viewModel.openedView = nil
            moverView?.remove(complete: { [weak self] in
                self?.viewModel.controllerView.isHidden = false
                moverView = nil
            })
            switch option {
            case .close:
                selectedView.restoreState(originalState)
            case .check:
                let newState = selectedView.captureCurrentState()
                selectedView.restoreState(originalState)
                selectedView.registerState(currentState: newState)
                self?.checkForUndoRedoAvailability()
            }
        }
        
        moverView?.selectedOption = { [weak self] option in
            switch option {
            case .up:
                UIView.animate(withDuration: 0.3, animations: {
                    selectedView.frame.origin.y -= intensity
                    self?.view.layoutIfNeeded()
                })
            case .down:
                UIView.animate(withDuration: 0.3, animations: {
                    selectedView.frame.origin.y += intensity
                    self?.view.layoutIfNeeded()
                })
            case .left:
                UIView.animate(withDuration: 0.3, animations: {
                    selectedView.frame.origin.x -= intensity
                    self?.view.layoutIfNeeded()
                })
            case .right:
                UIView.animate(withDuration: 0.3, animations: {
                    selectedView.frame.origin.x += intensity
                    self?.view.layoutIfNeeded()
                })
            }
        }
        
        if let moverView {
            viewModel.openedView = moverView
            viewModel.controllerView.isHidden = true
            self.view.addSubview(moverView)
            moverView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                moverView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                moverView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                moverView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    private func presentLockOptionView() {
        guard let selectedView = viewModel.selectedView else { return }
        
        let originalIsInteractionEnabled = selectedView.isUserInteractionEnabled
        let originalIsEditable = selectedView.isEditable
        let originalIsMovable = selectedView.movable

        var lockOptionView = UINib(nibName: "LockOptionView", bundle: packageBundle).instantiate(withOwner: nil).first as? LockOptionView
        lockOptionView?.selectedView = selectedView
        lockOptionView?.componentType = ComponentType(rawValue: selectedView.componentType ?? "")
        lockOptionView?.actionHappen = { [weak self] actionType in
            self?.viewModel.openedView = nil
            lockOptionView?.remove(complete: {
                lockOptionView = nil
            })
            switch actionType {
            case .close:
                selectedView.movable = originalIsMovable
                selectedView.isEditable = originalIsEditable
                selectedView.isUserInteractionEnabled = originalIsInteractionEnabled
                
                if selectedView.isUserInteractionEnabled {
                    self?.viewModel.selectedView = selectedView
                } else {
                    self?.viewModel.selectedView = nil
                }
                
            case .check:
                let newIsInteractionEnabled = selectedView.isUserInteractionEnabled
                let newIsEditable = selectedView.isEditable
                let newIsMovable = selectedView.movable
                
                selectedView.movable = originalIsMovable
                selectedView.isEditable = originalIsEditable
                selectedView.isUserInteractionEnabled = originalIsInteractionEnabled
                
                self?.setLockOptionIn(view: selectedView, isInteractionEnabled: newIsInteractionEnabled, isEditable: newIsEditable, isMoveable: newIsMovable)
            }
        }
        lockOptionView?.changedOption = { (option, isLocked) in
            switch option {
            case .interaction:
                selectedView.isUserInteractionEnabled = isLocked
            case .change:
                selectedView.isEditable = isLocked
            case .movement:
                selectedView.movable = isLocked
            }
        }
        
        if let lockOptionView {
            viewModel.openedView = lockOptionView
            self.view.addSubview(lockOptionView)
            lockOptionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                lockOptionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                lockOptionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                lockOptionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    private func presentImageEffectView(with type: EffectType) {
        guard let selectedView = viewModel.selectedView, let _ = selectedView.subviews.compactMap({ $0 as? UIImageView }).first else { return }
        
        var originalValue: CGFloat = 0
        switch type {
        case .blur:
            originalValue = selectedView.blurIntensity
        case .opacity:
            originalValue = selectedView.alpha
        default:
            break
        }
        
        let originalImage = selectedView.originalImage
        var effectView = UINib(nibName: "ImageEffectView", bundle: packageBundle).instantiate(withOwner: nil).first as? ImageEffectView
        effectView?.effectType = type
        effectView?.currentAdjustValue = originalValue * 100
        effectView?.intensityChanged = { intensity in
            switch type {
            case .blur:
                selectedView.blurIntensity = intensity
                selectedView.originalImage = originalImage
            case .opacity:
                selectedView.alpha = intensity
            default:
                break
            }
        }
        effectView?.actionHappen = { [weak self] action in
            effectView?.remove(complete: {
                effectView = nil
            })
            self?.viewModel.openedView = nil
            switch action {
            case .close:
                switch type {
                case .blur:
                    selectedView.blurIntensity = originalValue
                    selectedView.originalImage = originalImage
                case .opacity:
                    selectedView.alpha = originalValue
                default:
                    break
                }
            case .check:
                switch type {
                case .blur:
                    let newBlurIntensity = selectedView.blurIntensity
                    selectedView.blurIntensity = originalValue
                    self?.setBlurAlpha(intensity: newBlurIntensity, draggableView: selectedView)
                case .opacity:
                    let newAlpha = selectedView.alpha
                    selectedView.alpha = originalValue
                    self?.setViewOpacity(intensity: Float(newAlpha), view: selectedView)
                default:
                    break
                }
            }
        }
        if let effectView {
            viewModel.openedView = effectView
            self.view.addSubview(effectView)
            effectView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                effectView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                effectView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                effectView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    private func presentShadowEffectView() {
        guard let selectedView = self.viewModel.selectedView else { return }
        
        var shadowView = UINib(nibName: "ShadowView", bundle: packageBundle).instantiate(withOwner: nil).first as? ShadowView
        let originalOpacity = selectedView.layer.shadowOpacity
        let originalRadius = selectedView.layer.shadowRadius
        let originalOffset = selectedView.layer.shadowOffset
        shadowView?.currentShadow = (originalOpacity, originalRadius, originalOffset)
        
        shadowView?.actionHappen = { [weak self] type in
            self?.viewModel.openedView = nil
            shadowView?.remove(complete: {
                shadowView = nil
            })
            switch type {
            case .close:
                selectedView.layer.shadowOpacity = originalOpacity
                selectedView.layer.shadowRadius = originalRadius
                selectedView.layer.shadowOffset = originalOffset
            case .check:
                let newOpacity = selectedView.layer.shadowOpacity
                let newRadius = selectedView.layer.shadowRadius
                let newOffset = selectedView.layer.shadowOffset
                
                selectedView.layer.shadowOpacity = originalOpacity
                selectedView.layer.shadowRadius = originalRadius
                selectedView.layer.shadowOffset = originalOffset
                
                self?.setShadowInImage(opacity: newOpacity, radius: newRadius, offset: newOffset, view: selectedView)
            }
        }
        
        shadowView?.selectedShadow = { (opacity, radius, offset) in
            selectedView.layer.shadowOpacity = opacity
            selectedView.layer.shadowRadius = radius
            selectedView.layer.shadowOffset = offset
        }
        
        if let shadowView {
            viewModel.openedView = shadowView
            self.view.addSubview(shadowView)
            shadowView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                shadowView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                shadowView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                shadowView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    private func presentBlendModeView() {
        guard let selectedView = self.viewModel.selectedView else { return }
        
        let originalMode = selectedView.layer.compositingFilter
        let originalAlpha = selectedView.alpha
        var blendModeView = UINib(nibName: "BlendModeView", bundle: packageBundle).instantiate(withOwner: nil).first as? BlendModeView
        blendModeView?.originalMode = BlendMode(rawValue: originalMode as? String ?? "")
        blendModeView?.originalAlpha = originalAlpha
        blendModeView?.selectedBlendMode = { selectedMode, alpha in
            if selectedMode == .normal {
                selectedView.layer.compositingFilter = nil
                selectedView.alpha = alpha
            } else {
                selectedView.layer.compositingFilter = selectedMode.rawValue
                selectedView.alpha = alpha
            }
        }
        blendModeView?.actionHappen = { [weak self] type in
            self?.viewModel.openedView = nil
            blendModeView?.remove(complete: {
                blendModeView = nil
            })
            switch type {
            case .close:
                selectedView.layer.compositingFilter = originalMode
                selectedView.alpha = originalAlpha
            case .check:
                let currentFilter = selectedView.layer.compositingFilter
                let currentAlpha = selectedView.alpha
                selectedView.layer.compositingFilter = originalMode
                selectedView.alpha = originalAlpha
                self?.setBlendMode(blendMode: currentFilter, alpha: currentAlpha, in: selectedView)
            }
        }
        
        if let blendModeView {
            viewModel.openedView = blendModeView
            self.view.addSubview(blendModeView)
            blendModeView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                blendModeView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                blendModeView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                blendModeView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    private func presentAdjustmentView() {
        guard let selectedView = self.viewModel.selectedView, let selectedImageView = self.viewModel.selectedView?.subviews.compactMap({ $0 as? UIImageView }).first else { return }
        
        var newCIImage: CIImage = CIImage()
        let originalImage = selectedView.originalImage
        var adjustmentView = UINib(nibName: "AdjustmentView", bundle: packageBundle).instantiate(withOwner: nil).first as? AdjustmentView
        adjustmentView?.originalImg = CIImage(image: originalImage!)
        adjustmentView?.outputImg = { filteredImg in
            let contextCI = CIContext()
            if let cgImage = contextCI.createCGImage(filteredImg, from: filteredImg.extent) {
                selectedView.originalImage = UIImage(cgImage: cgImage)
                newCIImage = filteredImg
            }
        }
        adjustmentView?.actionHappen = { [weak self] type in
            self?.viewModel.openedView = nil
            adjustmentView?.remove(complete: {
                adjustmentView = nil
            })
            switch type {
            case .close:
                selectedView.originalImage = originalImage
            case .check:
                var newFilteredImg = originalImage
                let context = CIContext(options: nil)
                if let outputCGImage = context.createCGImage(newCIImage, from: newCIImage.extent) {
                    newFilteredImg = UIImage(cgImage: outputCGImage)
                } else {
                    newFilteredImg = selectedImageView.image
                }
                selectedView.originalImage = originalImage
                self?.setNewImage(newImg: newFilteredImg, in: selectedView)
            }
        }
        if let adjustmentView {
            viewModel.openedView = adjustmentView
            self.view.addSubview(adjustmentView)
            adjustmentView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                adjustmentView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                adjustmentView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                adjustmentView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    private func presentShapeView(forAdding: Bool = false) {
        let selectedView = self.viewModel.selectedView
        let imgView = selectedView?.subviews.compactMap({ $0 as? UIImageView }).first
        let originalShapeName = imgView?.stringTag ?? ""
        
        var shapeView = UINib(nibName: "ShapeSelectionView", bundle: packageBundle).instantiate(withOwner: nil).first as? ShapeSelectionView
        shapeView?.actionHappen = { [weak self] type in
            self?.viewModel.openedView = nil
            shapeView?.remove(complete: {
                shapeView = nil
            })
            if forAdding {
                return
            }
            switch type {
            case .close:
                selectedView?.originalImage = UIImage(named: originalShapeName)
                imgView?.stringTag = originalShapeName
            case .check:
                let newShapeName = imgView?.stringTag
                let newShapeImg = selectedView?.originalImage
                selectedView?.originalImage = UIImage(named: originalShapeName)
                imgView?.stringTag = originalShapeName
                self?.changeShapeImage(to: newShapeName, shapeImg: newShapeImg, shapeView: imgView ?? UIImageView(), in: selectedView ?? DraggableUIView())
            }
        }
        shapeView?.selectedShape = {[weak self] shapeName in
            if forAdding {
                self?.viewModel.openedView = nil
                shapeView?.remove(complete: {
                    shapeView = nil
                })
                self?.addShape(shapeName: shapeName)
            } else {
                guard let imgView = self?.viewModel.selectedView?.subviews.compactMap({ $0 as? UIImageView }).first else { return }
                selectedView?.originalImage = UIImage(named: shapeName)
                imgView.stringTag = shapeName
            }
        }
        
        if let shapeView {
            viewModel.openedView = shapeView
            self.view.addSubview(shapeView)
            shapeView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                shapeView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                shapeView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                shapeView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    private func presentMenuStylePicker() {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: ViewControllers.menuStyleSelectionStoryBoardID) as! MenuStyleSelection
        vc.modalPresentationStyle = .overCurrentContext
        
        vc.selectedMenuStyle = { style in
            if !style.isPremium || UserManager.shared.currentUserType == .paid {
                self.addMenuItem(type: style)
            } else {
                self.showPremiumFeatureAlert()
            }
        }
        
        self.present(vc, animated: true)
    }
    
    private func presentMenuFontSizeView() {
        guard let gridView = viewModel.selectedView?.subviews.compactMap({ $0 as? GridView }).first else { return }
        let originalNameSize = gridView.itemNameFontSize
        let originalDescriptionSize = gridView.itemDescriptionFontSize
        let originalValueSize = gridView.itemValueFontSize
        let originalNameFontStyle = gridView.itemNameFontStyle
        let originalDescriptionFontStyle = gridView.itemDescriptionFontStyle
        let originalValueFontStyle = gridView.itemValueFontStyle
        let originalHeadingColor = gridView.headingColor
        let originalDescriptionColor = gridView.descriptionColor
        let originalValueColor = gridView.valueColor
        var sliderValues: [ResizeOption: Float] = [:]
        sliderValues[.itemName] = Float(originalNameSize)
        sliderValues[.itemDescription] = Float(originalDescriptionSize)
        sliderValues[.itemValue] = Float(originalValueSize)
        
        var menuFontSizeView = UINib(nibName: "MenuFontSizeView", bundle: packageBundle).instantiate(withOwner: nil).first as? MenuFontSizeView
        menuFontSizeView?.sliderValues = sliderValues
        menuFontSizeView?.forStyle = gridView.menuStyle
        menuFontSizeView?.actionHappen = { [weak self] type in
            self?.viewModel.openedView = nil
            menuFontSizeView?.remove(complete: {
                menuFontSizeView = nil
            })
            switch type {
            case .close:
                gridView.itemNameFontSize = originalNameSize
                gridView.itemDescriptionFontSize = originalDescriptionSize
                gridView.itemValueFontSize = originalValueSize
                gridView.itemNameFontStyle = originalNameFontStyle
                gridView.itemDescriptionFontStyle = originalDescriptionFontStyle
                gridView.itemValueFontStyle = originalValueFontStyle
                gridView.headingColor = originalHeadingColor
                gridView.descriptionColor = originalDescriptionColor
                gridView.valueColor = originalValueColor
            case .check:
                let newNameSize = gridView.itemNameFontSize
                let newDescriptionSize = gridView.itemDescriptionFontSize
                let newValueSize = gridView.itemValueFontSize
                let newNameStyle = gridView.itemNameFontStyle
                let newDescriptionStyle = gridView.itemDescriptionFontStyle
                let newValueStyle = gridView.itemValueFontStyle
                let newHeadingColor = gridView.headingColor
                let newDescriptionColor = gridView.descriptionColor
                let newValueColor = gridView.valueColor
                
                gridView.itemNameFontSize = originalNameSize
                gridView.itemDescriptionFontSize = originalDescriptionSize
                gridView.itemValueFontSize = originalValueSize
                gridView.itemNameFontStyle = originalNameFontStyle
                gridView.itemDescriptionFontStyle = originalDescriptionFontStyle
                gridView.itemValueFontStyle = originalValueFontStyle
                gridView.headingColor = originalHeadingColor
                gridView.descriptionColor = originalDescriptionColor
                gridView.valueColor = originalValueColor
                self?.changeFontStyleInMenu(menu: gridView, nameSize: newNameSize, descriptionSize: newDescriptionSize, valueSize: newValueSize, nameStyle: newNameStyle, descriptionStyle: newDescriptionStyle, valueStyle: newValueStyle, headingColor: newHeadingColor, descriptionColor: newDescriptionColor, valueColor: newValueColor)
            }
        }
        
        menuFontSizeView?.adjustmentChanged = { option, size in
            switch option{
            case .itemName:
                gridView.itemNameFontSize = size
            case .itemDescription:
                gridView.itemDescriptionFontSize = size
            case .itemValue:
                gridView.itemValueFontSize = size
            }
        }
        
        menuFontSizeView?.presentFontPicker = { [weak self] option in
            let vc = self?.storyboard?.instantiateViewController(withIdentifier: "FontPickerController") as! FontPickerController
            vc.selectedFontDescriptor = { descriptor in
                guard let selectedFont = UIFont(name: descriptor, size: 19) else { return }
                switch option {
                case .itemName:
                    gridView.itemNameFontStyle = selectedFont.withSize(gridView.itemNameFontSize)
                case .itemDescription:
                    gridView.itemDescriptionFontStyle = selectedFont.withSize(gridView.itemValueFontSize)
                case .itemValue:
                    gridView.itemValueFontStyle = selectedFont.withSize(gridView.itemDescriptionFontSize)
                }
            }
            self?.present(vc, animated: true)
        }
        
        menuFontSizeView?.presentFontColorPicker = { [weak self] option in
            switch option {
            case .itemName:
                self?.presentColorPicker(for: .textColor, selectedColor: gridView.headingColor, menuField: .itemName)
            case .itemDescription:
                self?.presentColorPicker(for: .textColor, selectedColor: gridView.descriptionColor, menuField: .itemDescription)
            case .itemValue:
                self?.presentColorPicker(for: .textColor, selectedColor: gridView.valueColor, menuField: .itemValue)
            }
        }
        
        if let menuFontSizeView {
            viewModel.openedView = menuFontSizeView
            self.view.addSubview(menuFontSizeView)
            menuFontSizeView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                menuFontSizeView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                menuFontSizeView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                menuFontSizeView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    private func presentMenuSpacingAdjustView() {
        guard let selectedView = self.viewModel.selectedView, let gridView = selectedView.subviews.compactMap({ $0 as? GridView }).first else { return }
        let originalSpace = gridView.columnSpace
        let originalWidth = gridView.columnWidth
        var menuSpaceView = UINib(nibName: "MenuSpaceView", bundle: packageBundle).instantiate(withOwner: nil).first as? MenuSpaceView
        menuSpaceView?.valueSpace = originalSpace
        menuSpaceView?.valueWidth = originalWidth
        
        menuSpaceView?.actionHappen = { [weak self] action in
            self?.viewModel.openedView = nil
            menuSpaceView?.remove(complete: {
                menuSpaceView = nil
            })
            switch action {
            case .close:
                gridView.columnWidth = originalWidth
                gridView.columnSpace = originalSpace
            case .check:
                let newColumnWidth = gridView.columnWidth
                let newColumnSpace = gridView.columnSpace
                gridView.columnWidth = originalWidth
                gridView.columnSpace = originalSpace
                self?.setNewSpace(gridView: gridView, newWidth: newColumnWidth, newSpace: newColumnSpace)
            }
        }
        
        menuSpaceView?.spaceChanged = { option, space in
            switch option {
            case .valueSpace:
                gridView.columnSpace = space
            case .valueWidth:
                gridView.columnWidth = space
            }
        }
        
        if let menuSpaceView {
            viewModel.openedView = menuSpaceView
            self.view.addSubview(menuSpaceView)
            menuSpaceView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                menuSpaceView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                menuSpaceView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                menuSpaceView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        }
    }
    
    private func setDefaultDataIn(menu: GridView, scale: CGFloat) {
        let columnWidth = menu.columnWidth * scale
        menu.columnWidth = columnWidth
        let columnSpace = menu.columnSpace * scale
        menu.columnSpace = columnSpace
        let headingColor = menu.headingColor
        menu.headingColor = headingColor
        let descriptionColor = menu.descriptionColor
        menu.descriptionColor = descriptionColor
        let valueColor = menu.valueColor
        menu.valueColor = valueColor
        let itemNameFontSize = menu.itemNameFontSize * scale
        menu.itemNameFontSize = itemNameFontSize
        let itemDescriptionFontSize = menu.itemDescriptionFontSize * scale
        menu.itemDescriptionFontSize = itemDescriptionFontSize
        let itemValueFontSize = menu.itemValueFontSize * scale
        menu.itemValueFontSize = itemValueFontSize
        let itemNameFontStyle = menu.itemNameFontStyle
        menu.itemNameFontStyle = itemNameFontStyle
        let itemDescriptionFontStyle = menu.itemDescriptionFontStyle
        menu.itemDescriptionFontStyle = itemDescriptionFontStyle
        let itemValueFontStyle = menu.itemValueFontStyle
        menu.itemValueFontStyle = itemValueFontStyle
        menu.setNeedsLayout()
        menu.layoutIfNeeded()
        menu.layoutSubviews()
    }
}

// MARK: - Image Picker Delegate
extension EditorViewController: UIImagePickerControllerDelegate, UIDocumentPickerDelegate, UINavigationControllerDelegate  {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            let cropperVC = CropperViewController(originalImage: image)
            cropperVC.view.tag = picker.view.tag
            cropperVC.delegate = self
            self.present(cropperVC, animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first, url.startAccessingSecurityScopedResource() else { return }
        defer {
            DispatchQueue.main.async {
                url.stopAccessingSecurityScopedResource()
            }
        }
        guard let image = UIImage(contentsOfFile: url.path) else { return }
        let cropperVC = CropperViewController(originalImage: image)
        cropperVC.view.tag = controller.view.tag
        cropperVC.delegate = self
        self.present(cropperVC, animated: true)
        controller.dismiss(animated: true)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - CropperVC Delegate
extension EditorViewController: CropperViewControllerDelegate {
    func cropperDidConfirm(_ cropper: CropperViewController, state: CropperState?) {
        cropper.dismiss(animated: true)
        if let state = state,
           let image = cropper.originalImage.cropped(withCropperState: state) {
            switch cropper.view.tag {
            case 1:
                addImageToView(image)
                break
            case 2:
                if let selectedView = viewModel.selectedView {
                    let newSize = getImageRect(imageSize: image.size, viewSize: CGSize(width: 250, height: 250))
                    let originalFrame = CGRect(x: (selectedView.frame.origin.x + newSize.origin.x), y: (selectedView.frame.origin.y + newSize.origin.y), width: newSize.width, height: newSize.height)
                    self.changeImage(newImage: image, in: selectedView, with: originalFrame)
                }
            case 3:
                addBG(image: image)
            case 4:
                if let view = viewModel.selectedView {
                    self.addLayeredImage(in: view)
                }
            default:
                break
            }
        }
    }
    
    func cropperDidCancel(_ cropper: CropperViewController) {
        cropper.dismiss(animated: true)
    }
}

// MARK: - Component Edit with Undo Redo
extension EditorViewController {
    private func removeView(_ view: UIView) {
        UndoRedoManager.shared.registerUndo(target: self) { [weak self] target in
            self?.addView(view)
        }
        view.removeFromSuperview()
        viewModel.selectedView = nil
        self.checkForUndoRedoAvailability()
    }
    
    private func addView(_ view: UIView) {
        self.currentPage?.addSubview(view)
        if let draggableView = view as? DraggableUIView {
            viewModel.selectedView = draggableView
        }
        UndoRedoManager.shared.registerUndo(target: self) { [weak self] target in
            self?.removeView(view)
        }
        self.checkForUndoRedoAvailability()
    }
    
    private func addPageView(at index: Int, isFromDelete: Bool = false) {
        self.pageCount += 1
        let indexPath = IndexPath(item: index, section: 0)
        if isFromDelete {
            if index < self.pageCount - 1 {
                var maxIndex = self.pageCount - 1
                while maxIndex > index {
                    self.uniqueIdentifierIds[maxIndex] = self.uniqueIdentifierIds[(maxIndex - 1)]
                    maxIndex -= 1
                }
            }
            if let lastIndex = self.getLastDeletedIdentifierIndex(for: index) {
                self.uniqueIdentifierIds[index] = self.deletedIdentifierValue[lastIndex]
                self.deletedIdentifierValue.remove(at: lastIndex)
                self.deletedIdentifierId.remove(at: lastIndex)
            }
        }
        self.pageCollection.performBatchUpdates({
            self.pageCollection.insertItems(at: [indexPath])
        }, completion: { isCompleted in
            if isCompleted , !isFromDelete {
                if let bgImage = self.bgImage {
                    self.addBG(image: bgImage)
                } else if let img = self.getBGImageFromRecent() {
                    self.addBG(image: img)
                }
            }
            self.pageCollection.reloadData()
        })
        
        UndoRedoManager.shared.registerUndo(target: self) { [weak self] target in
            self?.removePageView(at: index)
        }
        
        self.checkForUndoRedoAvailability()
    }
    
    private func copyPageView(at index: Int, isFromDelete: Bool = false) {
        guard let originalPage = currentPage else { return }
        self.pageCount += 1
        if isFromDelete {
            if index < self.pageCount - 1 {
                var maxIndex = self.pageCount - 1
                while maxIndex > index {
                    self.uniqueIdentifierIds[maxIndex+1] = self.uniqueIdentifierIds[maxIndex]
                    maxIndex -= 1
                }
            }
            if let lastIndex = self.getLastDeletedIdentifierIndex(for: index) {
                self.uniqueIdentifierIds[index] = self.deletedIdentifierValue[lastIndex]
                self.deletedIdentifierValue.remove(at: lastIndex)
                self.deletedIdentifierId.remove(at: lastIndex)
            }
        }
        self.pageCollection.performBatchUpdates({
            self.pageCollection.insertItems(at: [IndexPath(item: index, section: 0)])
        }, completion: { _ in
            self.pageCollection.performBatchUpdates({
                self.pageCollection.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .centeredVertically)
            }, completion: { _ in
                if !isFromDelete {
                    for subView in originalPage.subviews {
                        if let draggableView = subView as? DraggableUIView {
                            self.duplicateElement(draggableView, byOffset: false)
                        }
                    }
                }
                self.pageCollection.reloadData()
            })
        })
        
        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] target in
            self?.removePageView(at: index, isCopy: true)
        })
        
        self.checkForUndoRedoAvailability()
    }
    
    private func addDeletedIdentifierIndex(at index: Int, value: Int) {
        self.deletedIdentifierId.insert(index, at: 0)
        self.deletedIdentifierValue.insert(value, at: 0)
    }
    
    private func getLastDeletedIdentifierIndex(for position: Int) -> Int? {
        var foundIndex: Int?
        if self.deletedIdentifierId.count > 0 {
            for (index, value) in self.deletedIdentifierId.enumerated() {
                if value == position {
                    foundIndex = index
                }
            }
        }
        return foundIndex
    }
    
    private func removePageView(at index: Int, isCopy: Bool = false) {
        self.pageCount -= 1
        let indexPath = IndexPath(item: index, section: 0)
        self.addDeletedIdentifierIndex(at: index, value: self.uniqueIdentifierIds[index] ?? 999)
        if index < self.pageCount {
            for index in index...self.pageCount - 1 {
                self.uniqueIdentifierIds[index] = self.uniqueIdentifierIds[(index+1)]
                self.uniqueIdentifierIds.removeValue(forKey: (index+1))
            }
        } else {
            self.uniqueIdentifierIds.removeValue(forKey: index)
        }
        self.pageCollection.performBatchUpdates({
            self.pageCollection.deleteItems(at: [indexPath])
        }, completion: { _ in
            self.pageCollection.reloadData()
        })
        
        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] target in
            if isCopy {
                self?.copyPageView(at: index, isFromDelete: true)
            } else {
                self?.addPageView(at: index, isFromDelete: true)
            }
        })
        
        self.checkForUndoRedoAvailability()
    }
    
    private func insertSubViewAt(position: Int, view: UIView, parentView: UIView) {
        let previousIndex = parentView.subviews.firstIndex(of: view) ?? 1
        
        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] target in
            self?.insertSubViewAt(position: previousIndex, view: view, parentView: parentView)
        })
        
        view.removeFromSuperview()
        parentView.insertSubview(view, at: position)
        DispatchQueue.main.async {
            if let draggableView = view as? DraggableUIView {
                self.viewModel.selectedView = draggableView
            }
        }
        self.checkForUndoRedoAvailability()
    }
    
    private func setLockOptionIn(view: DraggableUIView, isInteractionEnabled: Bool, isEditable: Bool, isMoveable: Bool) {
        let previousIsInteractionEnabled = view.isUserInteractionEnabled
        let previousIsEditable = view.isEditable
        let previousIsMovable = view.movable
        
        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] target in
            self?.setLockOptionIn(view: view, isInteractionEnabled: previousIsInteractionEnabled, isEditable: previousIsEditable, isMoveable: previousIsMovable)
        })
        
        view.isUserInteractionEnabled = isInteractionEnabled
        view.movable = isMoveable
        view.isEditable = isEditable
        
        if view.isUserInteractionEnabled {
            self.viewModel.selectedView = view
        } else {
            self.viewModel.selectedView = nil
        }
        
        self.checkForUndoRedoAvailability()
    }
    
    private func setBackgroundColor(_ color: UIColor?, view: UIView) {
        let previousColor = view.backgroundColor
        
        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] target in
            self?.setBackgroundColor(previousColor, view: view)
        })
        view.backgroundColor = color
        self.checkForUndoRedoAvailability()
    }
    
    private func setFontColor(_ color: UIColor?, lbl: UITextView) {
        let previousColor = lbl.textColor
        
        UndoRedoManager.shared.registerUndo(target: self) { [weak self] target in
            self?.setFontColor(previousColor, lbl: lbl)
        }
        
        lbl.textColor = color
        self.checkForUndoRedoAvailability()
    }
    
    private func setNewData(data: [MenuItemDetails], in view: GridView) {
        let previousData = view.data
        
        UndoRedoManager.shared.registerUndo(target: self) { [weak self] target in
            self?.setNewData(data: previousData, in: view)
        }
        
        view.data = data
        self.checkForUndoRedoAvailability()
    }
    
    private func setBlendMode(blendMode: Any?, alpha: CGFloat, in view: UIView) {
        let previousBlendMode = view.layer.compositingFilter
        let previousAlpha = view.alpha
        
        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] target in
            self?.setBlendMode(blendMode: previousBlendMode, alpha: previousAlpha, in: view)
        })
        
        view.alpha = alpha
        view.layer.compositingFilter = blendMode
        self.checkForUndoRedoAvailability()
    }
    
    private func setNewImage(newImg: UIImage?, in view: DraggableUIView) {
        let previousImg = view.originalImage
        
        UndoRedoManager.shared.registerUndo(target: self) { [weak self] target in
            self?.setNewImage(newImg: previousImg, in: view)
        }
        
        view.originalImage = newImg
        self.checkForUndoRedoAvailability()
    }
    
    private func changeImage(newImage: UIImage?, in view: DraggableUIView, with rect: CGRect?) {
        let previousImg = view.originalImage
        let previousRect = view.frame
        let previousCenter = view.center
        
        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] target in
            self?.changeImage(newImage: previousImg, in: view, with: previousRect)
        })
        
        view.originalImage = newImage
        if let rect {
            view.frame = rect
            view.center = previousCenter
        }
        
        self.checkForUndoRedoAvailability()
    }
    
    private func setFont(for label: UITextView, to font: UIFont?) {
        guard let newFont = font else { return }
        let oldFont = label.font
        
        UndoRedoManager.shared.registerUndo(target: self) { [weak self] _ in
            guard let self = self else { return }
            self.setFont(for: label, to: oldFont)
        }
        
        label.font = newFont
        self.checkForUndoRedoAvailability()
    }
    
    private func setTintColor(in view: UIImageView, tintColor: UIColor) {
        let oldColor = view.tintColor ?? .tintColor

        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] _ in
            self?.setTintColor(in: view, tintColor: oldColor)
        })

        view.tintColor = tintColor
        self.checkForUndoRedoAvailability()
    }
    
    private func setViewOpacity(intensity: Float, view: UIView) {
        let previousOpacity = view.layer.opacity
        
        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] _ in
            self?.setViewOpacity(intensity: previousOpacity, view: view)
        })
        
        view.layer.opacity = intensity
        self.checkForUndoRedoAvailability()
    }
    
    private func setBlurAlpha(intensity: CGFloat, draggableView: DraggableUIView) {
        let previousBlurIntensity = draggableView.blurIntensity
        
        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] _ in
            self?.setBlurAlpha(intensity: previousBlurIntensity, draggableView: draggableView)
        })
        
        draggableView.blurIntensity = intensity
        let img = draggableView.originalImage
        draggableView.originalImage = img
        self.checkForUndoRedoAvailability()
    }
    
    private func setShadowInImage(opacity: Float, radius: CGFloat, offset: CGSize, view: UIView) {
        let previousOpacity = view.layer.shadowOpacity
        let previousRadius = view.layer.shadowRadius
        let previousOffset = view.layer.shadowOffset
        
        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] _ in
            self?.setShadowInImage(opacity: previousOpacity, radius: previousRadius, offset: previousOffset, view: view)
        })
        
        view.layer.shadowOpacity = opacity
        view.layer.shadowRadius = radius
        view.layer.shadowOffset = offset
    }
    
    private func changeShapeImage(to shapeName: String?, shapeImg: UIImage?, shapeView: UIImageView, in view: DraggableUIView) {
        let oldShape = shapeView.stringTag
        let oldShapeImg = view.originalImage
        
        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] _ in
            self?.changeShapeImage(to: oldShape, shapeImg: oldShapeImg, shapeView: shapeView, in: view)
        })

        shapeView.stringTag = shapeName
        view.originalImage = shapeImg
        self.checkForUndoRedoAvailability()
    }
    
    private func deleteElement() {
        if let selectedView = viewModel.selectedView, selectedView.isRemovable {
            viewModel.selectedView = nil
            UndoRedoManager.shared.registerUndo(target: self) { [weak self] target in
                self?.addView(selectedView)
            }
            
            selectedView.removeFromSuperview()
        }
        self.viewModel.selectedView = nil
        self.checkForUndoRedoAvailability()
    }
    
    private func changeTextOfLabel(label: UITextView, newText: String?, newSize: CGFloat?, newFrame: CGRect?) {
        let oldText = label.text
        let oldSize = label.font?.pointSize
        let oldFrame = label.superview?.frame
        
        UndoRedoManager.shared.registerUndo(target: self) { [weak self] _ in
            self?.changeTextOfLabel(label: label, newText: oldText, newSize: oldSize, newFrame: oldFrame)
        }
        
        label.text = newText
        label.font = label.font?.withSize(newSize ?? 0)
        label.superview?.frame = newFrame ?? CGRect()
        self.checkForUndoRedoAvailability()
    }
    
    private func changeFontStyleInMenu(menu: GridView, nameSize: CGFloat, descriptionSize: CGFloat, valueSize: CGFloat, nameStyle: UIFont, descriptionStyle: UIFont, valueStyle: UIFont, headingColor: UIColor, descriptionColor: UIColor, valueColor: UIColor) {
        let previousNameSize = menu.itemNameFontSize
        let previousDescriptionSize = menu.itemDescriptionFontSize
        let previousValueSize = menu.itemValueFontSize
        let previousNameStyle = menu.itemNameFontStyle
        let previousDescriptionStyle = menu.itemDescriptionFontStyle
        let previousValueStyle = menu.itemValueFontStyle
        let previousHeadingColor = menu.headingColor
        let previousDescriptionColor = menu.descriptionColor
        let previousValueColor = menu.valueColor
        
        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] target in
            self?.changeFontStyleInMenu(menu: menu, nameSize: previousNameSize, descriptionSize: previousDescriptionSize, valueSize: previousValueSize, nameStyle: previousNameStyle, descriptionStyle: previousDescriptionStyle, valueStyle: previousValueStyle, headingColor: previousHeadingColor, descriptionColor: previousDescriptionColor, valueColor: previousValueColor)
        })
        
        menu.itemNameFontSize = nameSize
        menu.itemDescriptionFontSize = descriptionSize
        menu.itemValueFontSize = valueSize
        menu.itemNameFontStyle = nameStyle
        menu.itemDescriptionFontStyle = descriptionStyle
        menu.itemValueFontStyle = valueStyle
        menu.headingColor = headingColor
        menu.descriptionColor = descriptionColor
        menu.valueColor = valueColor
        self.checkForUndoRedoAvailability()
    }
    
    private func setNewData(in gridView: GridView, newData: [MenuItemDetails], newFrame: CGRect?) {
        let oldData = gridView.data
        let oldFrame = gridView.superview?.frame
        
        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] target in
            self?.setNewData(in: gridView, newData: oldData, newFrame: oldFrame)
        })
        
        gridView.data = newData
        gridView.superview?.frame = newFrame ?? CGRect()
//        self.setDefaultDataIn(menu: gridView, scale: 0.8)
        DispatchQueue.main.async {
            self.setDefaultDataIn(menu: gridView, scale: 1)
        }
        self.checkForUndoRedoAvailability()
    }
    
    private func setNewSpace(gridView: GridView, newWidth: CGFloat, newSpace: CGFloat) {
        let previousWidth = gridView.columnWidth
        let previousSpace = gridView.columnSpace
        
        UndoRedoManager.shared.registerUndo(target: self, handler: { [weak self] target in
            self?.setNewSpace(gridView: gridView, newWidth: previousWidth, newSpace: previousSpace)
        })
        
        gridView.columnWidth = newWidth
        gridView.columnSpace = newSpace
        self.checkForUndoRedoAvailability()
    }
}

// MARK: - View Adding Methods
extension EditorViewController {
    private func configureDraggableView(_ view: DraggableUIView, with element: UIElement, scaleX: CGFloat, scaleY: CGFloat) {
        view.frame = CGRect(
            x: element.x * scaleX,
            y: element.y * scaleY,
            width: element.width * scaleX,
            height: element.height * scaleY
        )
        view.componentType = element.type
        view.movable = element.movable ?? true
        view.isRemovable = element.isRemovable ?? true
        view.isEditable = element.isEditable ?? true
        view.isDuplicatable = element.isDuplicatable ?? true
        view.isUserInteractionEnabled = element.isUserInteractionEnabled ?? true //c
        view.layer.borderWidth = 2
        view.layer.borderColor = UIColor.clear.cgColor
        view.translatesAutoresizingMaskIntoConstraints = true
        if let rotationAngle = element.rotationAngle {
            view.transform = view.transform.rotated(by: rotationAngle)
        }
        
        if let blendMode = element.blendMode {
            view.layer.compositingFilter = blendMode
        }
        
        view.layer.shadowColor = UIColor.black.cgColor
        if let opacity = element.shadowOpacity {
            view.layer.shadowOpacity = opacity
        }
        if let radius = element.shadowRadius {
            view.layer.shadowRadius = radius
        }
        if let widthOffset = element.shadowOffsetWidth, let heightOffset = element.shadowOffsetHeight {
            view.layer.shadowOffset = CGSize(width: widthOffset, height: heightOffset)
        }
        
        if let bgColorHex = element.backGroundColor, !bgColorHex.isEmpty {
            view.backgroundColor = UIColor(hex: bgColorHex)
        } else {
            view.backgroundColor = UIColor.clear
        }
        if let cornerRadius = element.cornerRadius {
            view.layer.cornerRadius = CGFloat(cornerRadius) * min(scaleX, scaleY)
            view.clipsToBounds = true
        }
    }
    
    private func setConstraints(for subview: UIView, in container: UIView) {
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            subview.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: 0),
            subview.topAnchor.constraint(equalTo: container.topAnchor, constant: 0),
            subview.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: 0)
        ])
    }
    
    private func adjustTextHeight(txtView: UITextView, view: UIView) {
        let newSize = txtView.sizeThatFits(CGSize(width: view.frame.width, height: CGFloat.greatestFiniteMagnitude))
        txtView.frame.size.height = newSize.height
        view.frame.size.height = newSize.height
    }
    
    private func createLabel(with element: UIElement, fontFamily: UIFont, scaleX: CGFloat, scaleY: CGFloat) -> DraggableUIView {
        let draggableLabelView = DraggableUIView()
        configureDraggableView(draggableLabelView, with: element, scaleX: scaleX, scaleY: scaleY)
        
        let txtView = UITextView()
        txtView.text = element.text ?? "Text"
        txtView.textColor = UIColor(hex: element.textColor ?? "#000000")
        txtView.textAlignment = NSTextAlignment(rawValue: element.alignment ?? 1) ?? .center
        txtView.font = fontFamily
        txtView.backgroundColor = .clear
        txtView.isEditable = false
        txtView.isSelectable = false
        txtView.isScrollEnabled = false
        txtView.translatesAutoresizingMaskIntoConstraints = false
        draggableLabelView.addSubview(txtView)
        setConstraints(for: txtView, in: draggableLabelView)
        
        addGesture(draggableLabelView)
        currentPage?.addSubview(draggableLabelView)
        return draggableLabelView
    }
    
    private func createImageView(with element: UIElement, scaleX: CGFloat, scaleY: CGFloat) {
        let draggableImageView = DraggableUIView()
        configureDraggableView(draggableImageView, with: element, scaleX: scaleX, scaleY: scaleY)
        
        var originalImage: UIImage?
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let urlString = element.url {
            imageView.setImage(urlString: urlString, completionHandler: { [weak self] in
                originalImage = imageView.image
                draggableImageView.originalImage = originalImage
                if element.isLayeredImg ?? false {
                    draggableImageView.isLayered = true
                    self?.addLayeredImage(in: draggableImageView)
                }
                if let blurAlpha = element.blurAlpha {
                    draggableImageView.blurIntensity = blurAlpha
                    draggableImageView.originalImage = originalImage
                }
                if draggableImageView.frame.width >= self?.widthSize ?? 0 && draggableImageView.frame.height >= self?.heightSize ?? 0, draggableImageView.frame.origin.x < 0, draggableImageView.frame.origin.y < 0 , element.isUserInteractionEnabled == false {
                    self?.bgImage = imageView.image
                }
            })
        }
        imageView.contentMode = UIView.ContentMode(rawValue: element.contentMode ?? 1) ?? .scaleAspectFit
        draggableImageView.addSubview(imageView)
        setConstraints(for: imageView, in: draggableImageView)
        
        if let originalImage {
            if let blurAlpha = element.blurAlpha {
                draggableImageView.blurIntensity = blurAlpha
                draggableImageView.originalImage = originalImage
            }
        }
        
        addGesture(draggableImageView)
        currentPage?.addSubview(draggableImageView)
    }
    
    private func createMenuView(with element: UIElement, scaleX: CGFloat, scaleY: CGFloat) {
        let draggableMenuView = DraggableUIView()
        configureDraggableView(draggableMenuView, with: element, scaleX: scaleX, scaleY: scaleY)
        
        let gridView = GridView(frame: .zero)
        gridView.menuStyle = MenuStyle(rawValue: element.menuStyle ?? 1) ?? .type1
        self.applyMenuContent(for: gridView, element: element, scaleX: 1, scaleY: 1)
        gridView.data = element.menuData ?? []
        gridView.translatesAutoresizingMaskIntoConstraints = false
        draggableMenuView.addSubview(gridView)
        setConstraints(for: gridView, in: draggableMenuView)
        currentPage?.addSubview(draggableMenuView)
        self.applyMenuContent(for: gridView, element: element, scaleX: scaleX, scaleY: scaleY)
        addGesture(draggableMenuView)
    }
    
    private func applyMenuContent(for gridView: GridView, element: UIElement, scaleX: CGFloat, scaleY: CGFloat) {
        gridView.columnWidth = ((element.columnWidth ?? 30) * min(scaleX, scaleY))
        gridView.columnSpace = ((element.columnSpace ?? 0) * min(scaleX, scaleY))
        if let colorCode = element.itemNameTextColor, let color = UIColor(hex: colorCode) {
            gridView.headingColor = color
        }
        if let colorCode = element.itemDescriptionTextColor, let color = UIColor(hex: colorCode) {
            gridView.descriptionColor = color
        }
        if let colorCode = element.itemValueTextColor, let color = UIColor(hex: colorCode) {
            gridView.valueColor = color
        }
        gridView.itemNameFontSize = ((element.itemNameFontSize ?? 19) * min(scaleX, scaleY))
        gridView.itemDescriptionFontSize = ((element.itemDescriptionFontSize ?? 17) * min(scaleX, scaleY))
        gridView.itemValueFontSize = ((element.itemValueFontSize ?? 17) * min(scaleX, scaleY))
        
        if let font = UIFont(name: element.itemNameFontStyle ?? "", size: gridView.itemNameFontSize) {
            gridView.itemNameFontStyle = font
        }
        if let font = UIFont(name: element.itemDescriptionFontStyle ?? "", size: gridView.itemDescriptionFontSize) {
            gridView.itemDescriptionFontStyle = font
        }
        if let font = UIFont(name: element.itemValueFontStyle ?? "", size: gridView.itemValueFontSize) {
            gridView.itemValueFontStyle = font
        }
    }
    
    private func createShapeView(with element: UIElement, scaleX: CGFloat, scaleY: CGFloat) {
        let draggableShapeView = DraggableUIView()
        configureDraggableView(draggableShapeView, with: element, scaleX: scaleX, scaleY: scaleY)
        
        let shapeView = UIImageView()
        shapeView.tintColor = .white
        shapeView.contentMode = .scaleToFill
        shapeView.tintAdjustmentMode = .normal
        shapeView.translatesAutoresizingMaskIntoConstraints = false
        if let urlString = element.url {
            shapeView.setImage(urlString: urlString)
            shapeView.stringTag = urlString
            draggableShapeView.originalImage = shapeView.image
        }
        if let tintColor = element.tintColor, let tintColor = UIColor(hex: tintColor) {
            shapeView.tintColor = tintColor
            shapeView.image = shapeView.image
        }
        draggableShapeView.addSubview(shapeView)
        setConstraints(for: shapeView, in: draggableShapeView)
        
        if let blurAlpha = element.blurAlpha {
            draggableShapeView.blurIntensity = blurAlpha
            draggableShapeView.originalImage = shapeView.image
        }
        
        addGesture(draggableShapeView)
        currentPage?.addSubview(draggableShapeView)
    }
    
    private func addLayeredImage(in view: DraggableUIView, image: UIImage? = nil, frame: CGRect? = nil) {
        let newImageView = UIImageView()
        newImageView.contentMode = .scaleAspectFit
        newImageView.backgroundColor = .white
        
        let draggableView = DraggableUIView()
        draggableView.componentType = ComponentType.image.rawValue
        let btn = UIButton()
        btn.frame.size = CGSize(width: 30, height: 30)
        if let imageView = view.subviews.first as? UIImageView {
            imageView.isUserInteractionEnabled = false
            draggableView.frame = CGRect(origin: .zero, size: view.frame.size)
            let layer = CALayer()
            layer.frame = draggableView.layer.frame
            let maskImg = extractWhiteAreas(from: imageView.image ?? UIImage())?.cgImage
            layer.contents = maskImg
            draggableView.layer.mask = layer
            btn.center = imageView.center
        }
        
        draggableView.addSubview(newImageView)
        newImageView.frame = draggableView.bounds
        addGesture(draggableView)
        view.addSubview(draggableView)
        view.movable = false
        draggableView.movable = false
        newImageView.enableZoom()
        
        btn.setImage(UIImage(named: "addItem"), for: .normal)
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(addImageToLayerBtnTapped(_:)), for: .touchUpInside)
        draggableView.addSubview(btn)
        newImageView.image = image
        if let frame {
            newImageView.frame = frame
        }
    }
    
    private func addLabelView() {
        let data: DynamicUIData = DynamicUIData(superViewWidth: self.widthSize, superViewHeight: self.heightSize, preview_img: "", outputWidth: (Float(self.widthSize) * 9), outputHeight: (Float(self.heightSize) * 9), elements: [:])
        
        let scaleX = self.widthSize / data.superViewWidth
        let scaleY = self.heightSize / data.superViewHeight
        let size = CGSize(width: 150, height: 70)
        let element = UIElement(type: ComponentType.label.rawValue, x: ((widthSize / 2) - (size.width / 2)), y: ((heightSize / 2) - (size.height / 2)), width: size.width, height: size.height, movable: nil, isUserInteractionEnabled: nil, alpha: 1, isDuplicatable: nil, isRemovable: nil, cornerRadius: nil, backGroundColor: nil, rotationAngle: 0, text: "Your text here", alignment: nil, textColor: nil, fontURL: nil, size: nil, isEditable: nil, contentMode: nil, url: nil, itemNameFontSize: nil, itemDescriptionFontSize: nil, itemValueFontSize: nil, columnWidth: nil, columnSpace: 0, menuData: nil)
        let newView = createLabel(with: element, fontFamily: UIFont.systemFont(ofSize: 18 * min(scaleX, scaleY)), scaleX: scaleX, scaleY: scaleY)
        viewModel.selectedView = newView
        UndoRedoManager.shared.registerUndo(target: self) { [weak self] target in
            self?.removeView(newView)
        }
        self.checkForUndoRedoAvailability()
    }
    
    private func addMenuItem(type: MenuStyle) {
        let data: DynamicUIData = DynamicUIData(superViewWidth: self.widthSize, superViewHeight: self.heightSize, preview_img: "", outputWidth: (Float(self.widthSize) * 9), outputHeight: (Float(self.heightSize) * 9), elements: [:])
        
        let scaleX = self.widthSize / data.superViewWidth
        let scaleY = self.heightSize / data.superViewHeight
        let size = CGSize(width: 250, height: 250)
        let element = UIElement(type: ComponentType.menuBox.rawValue, x: ((widthSize / 2) - (size.width / 2)), y: ((heightSize / 2) - (size.height / 2)), width: size.width, height: size.height, movable: nil, isUserInteractionEnabled: nil, alpha: 1, isDuplicatable: nil, isRemovable: nil, cornerRadius: nil, backGroundColor: nil, rotationAngle: 0, text: "Your text here", alignment: nil, textColor: nil, fontURL: nil, size: nil, isEditable: nil, contentMode: nil, itemNameFontSize: nil, itemDescriptionFontSize: nil, itemValueFontSize: nil, columnWidth: nil, columnSpace: 0, menuData: nil)
        
        DispatchQueue.main.async { [self] in
            let draggableMenuView = DraggableUIView()
            configureDraggableView(draggableMenuView, with: element, scaleX: scaleX, scaleY: scaleY)
            
            let menuItem = GridView(frame: .zero)
            draggableMenuView.addSubview(menuItem)
            menuItem.menuStyle = type
            menuItem.itemNameFontSize = type.itemNameFontSize
            menuItem.itemDescriptionFontSize = type.itemDescriptionFontSize
            menuItem.itemValueFontSize = type.itemValueFontSize
            menuItem.itemNameFontStyle = type.itemNameStyle
            menuItem.itemDescriptionFontStyle = type.itemDescriptionStyle
            menuItem.itemValueFontStyle = type.itemValueFontStyle
            if let (itemName, itemDescription, itemValue) = getMenuColorFromData() {
                menuItem.headingColor = UIColor(hex: itemName ?? "") ?? UIColor.black
                menuItem.descriptionColor = UIColor(hex: itemDescription ?? "") ?? UIColor.black
                menuItem.valueColor = UIColor(hex: itemValue ?? "") ?? UIColor.black
            }
            menuItem.columnWidth = 30
            switch type {
            case .type1:
                menuItem.data = self.viewModel.menuData
            case .type2:
                menuItem.data = self.viewModel.menuData
            case .type3:
                menuItem.data = self.viewModel.menuData
            case .type4:
                menuItem.data = self.viewModel.menuData4
            case .type5:
                menuItem.data = self.viewModel.menuData4
            case .type6:
                menuItem.data = self.viewModel.menuData6
            case .type7:
                menuItem.data = self.viewModel.menuData7
            case .type8:
                menuItem.data = self.viewModel.menuData7
            case .type9:
                menuItem.data = self.viewModel.menuData
            case .type10:
                menuItem.data = self.viewModel.menuData10
            case .type11:
                menuItem.data = self.viewModel.menuData7
            case .type12:
                menuItem.data = self.viewModel.menuData
            case .type13:
                menuItem.data = self.viewModel.menuData
            }
            menuItem.translatesAutoresizingMaskIntoConstraints = false
            setConstraints(for: menuItem, in: draggableMenuView)
            
            addGesture(draggableMenuView)
            currentPage?.addSubview(draggableMenuView)
            viewModel.selectedView = draggableMenuView
            UndoRedoManager.shared.registerUndo(target: self) { [weak self] target in
                self?.removeView(draggableMenuView)
            }
            self.checkForUndoRedoAvailability()
        }
    }
    
    private func addImageToView(_ image: UIImage) {
        let newImageView = UIImageView(image: image)
        newImageView.contentMode = .scaleToFill
        newImageView.backgroundColor = .clear
        newImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let draggableView = DraggableUIView()
        draggableView.componentType = ComponentType.image.rawValue
        draggableView.originalImage = image
        let size = CGSize(width: 250, height: 250)
        let newSize = getImageRect(imageSize: image.size, viewSize: size).size
        draggableView.frame = CGRect(x: ((self.widthSize / 2) - (newSize.width / 2)), y: ((self.heightSize / 2) - (newSize.height / 2)), width: newSize.width, height: newSize.height)
        draggableView.addSubview(newImageView)
        
        NSLayoutConstraint.activate([
            newImageView.leadingAnchor.constraint(equalTo: draggableView.leadingAnchor),
            newImageView.trailingAnchor.constraint(equalTo: draggableView.trailingAnchor),
            newImageView.topAnchor.constraint(equalTo: draggableView.topAnchor),
            newImageView.bottomAnchor.constraint(equalTo: draggableView.bottomAnchor)
        ])
        
        addGesture(draggableView)
        currentPage?.addSubview(draggableView)
        viewModel.selectedView = draggableView
        UndoRedoManager.shared.registerUndo(target: self) { [weak self] target in
            self?.removeView(draggableView)
        }
        self.checkForUndoRedoAvailability()
    }
    
    private func addShape(shapeName: String) {
        let newImageView = UIImageView(image: UIImage(named: shapeName))
        newImageView.stringTag = shapeName
        newImageView.tintAdjustmentMode = .normal
        newImageView.tintColor = .white
        newImageView.contentMode = .scaleToFill
        newImageView.backgroundColor = .clear
        newImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let draggableView = DraggableUIView()
        draggableView.componentType = ComponentType.shape.rawValue
        draggableView.originalImage = newImageView.image
        let size = CGSize(width: 250, height: 250)
        let newSize = getImageRect(imageSize: newImageView.image?.size ?? CGSize(), viewSize: size).size
        draggableView.frame = CGRect(x: ((self.widthSize / 2) - (newSize.width / 2)), y: ((self.heightSize / 2) - (newSize.height / 2)), width: newSize.width, height: newSize.height)
        draggableView.addSubview(newImageView)
        
        NSLayoutConstraint.activate([
            newImageView.leadingAnchor.constraint(equalTo: draggableView.leadingAnchor),
            newImageView.trailingAnchor.constraint(equalTo: draggableView.trailingAnchor),
            newImageView.topAnchor.constraint(equalTo: draggableView.topAnchor),
            newImageView.bottomAnchor.constraint(equalTo: draggableView.bottomAnchor)
        ])
        
        addGesture(draggableView)
        currentPage?.addSubview(draggableView)
        viewModel.selectedView = draggableView
        UndoRedoManager.shared.registerUndo(target: self) { [weak self] target in
            self?.removeView(draggableView)
        }
        self.checkForUndoRedoAvailability()
    }
    
    private func duplicateElement(_ originalView: DraggableUIView, byOffset: Bool = true) {
        // Create a new instance of DraggableUIView
        let duplicatedView = DraggableUIView()
        
        // Copy properties from the original view to the duplicated view
        let originalTransform = originalView.transform
        originalView.transform = .identity
        if byOffset {
            duplicatedView.frame = originalView.frame.offsetBy(dx: 10, dy: 10) // Offset slightly for visibility
        } else {
            duplicatedView.frame = originalView.frame
        }
        originalView.transform = originalTransform
        duplicatedView.transform = originalTransform
        duplicatedView.componentType = originalView.componentType
        duplicatedView.movable = originalView.movable
        duplicatedView.isRemovable = originalView.isRemovable
        duplicatedView.isEditable = originalView.isEditable
        duplicatedView.isDuplicatable = originalView.isDuplicatable
        duplicatedView.isUserInteractionEnabled = originalView.isUserInteractionEnabled
        duplicatedView.backgroundColor = originalView.backgroundColor
        duplicatedView.layer.cornerRadius = originalView.layer.cornerRadius
        duplicatedView.clipsToBounds = originalView.clipsToBounds
        duplicatedView.layer.shadowOffset = originalView.layer.shadowOffset
        duplicatedView.layer.shadowOpacity = originalView.layer.shadowOpacity
        duplicatedView.layer.shadowRadius = originalView.layer.shadowRadius
        duplicatedView.layer.compositingFilter = originalView.layer.compositingFilter
        
        // Duplicate subviews
        for subview in originalView.subviews {
            if let label = subview as? UITextView {
                let duplicatedLabel = UITextView()
                duplicatedLabel.text = label.text
                duplicatedLabel.textColor = label.textColor
                duplicatedLabel.font = label.font
                duplicatedLabel.textAlignment = label.textAlignment
                duplicatedLabel.backgroundColor = label.backgroundColor
                duplicatedLabel.isEditable = false
                duplicatedLabel.isSelectable = false
                duplicatedLabel.isScrollEnabled = false
                duplicatedLabel.translatesAutoresizingMaskIntoConstraints = false
                duplicatedView.addSubview(duplicatedLabel)
                self.setConstraints(for: duplicatedLabel, in: duplicatedView)
            } else if let imageView = subview as? UIImageView {
                let duplicatedImageView = UIImageView()
                duplicatedImageView.image = imageView.image
                duplicatedImageView.contentMode = imageView.contentMode
                duplicatedImageView.stringTag = imageView.stringTag
                duplicatedImageView.tintColor = imageView.tintColor
                duplicatedImageView.translatesAutoresizingMaskIntoConstraints = false
                duplicatedView.addSubview(duplicatedImageView)
                duplicatedView.originalImage = originalView.originalImage
                self.setConstraints(for: duplicatedImageView, in: duplicatedView)
            } else if let gridView = subview as? GridView {
                let duplicateGridView = GridView(frame: .zero)
                duplicateGridView.menuStyle = gridView.menuStyle
                duplicateGridView.columnWidth = gridView.columnWidth
                duplicateGridView.columnSpace = gridView.columnSpace
                duplicateGridView.itemNameFontSize = gridView.itemNameFontSize
                duplicateGridView.itemDescriptionFontSize = gridView.itemDescriptionFontSize
                duplicateGridView.itemValueFontSize = gridView.itemValueFontSize
                duplicateGridView.itemNameFontStyle = gridView.itemNameFontStyle
                duplicateGridView.itemDescriptionFontStyle = gridView.itemDescriptionFontStyle
                duplicateGridView.itemValueFontStyle = gridView.itemValueFontStyle
                duplicateGridView.headingColor = gridView.headingColor
                duplicateGridView.descriptionColor = gridView.descriptionColor
                duplicateGridView.valueColor = gridView.valueColor
                duplicateGridView.data = gridView.data
                duplicateGridView.translatesAutoresizingMaskIntoConstraints = false
                duplicatedView.addSubview(duplicateGridView)
                self.setConstraints(for: duplicateGridView, in: duplicatedView)
            }
        }
        
        addGesture(duplicatedView)
        currentPage?.addSubview(duplicatedView)
        UndoRedoManager.shared.registerUndo(target: self) { [weak self] _ in
            self?.removeView(duplicatedView)
        }
        if byOffset {
            self.viewModel.selectedView = duplicatedView
        }
    }
    
    func addBG(image: UIImage)  {
        self.bgImage = image
        let height = image.size.height
        let width = image.size.width
        
        let aspectRatio = height / width
        let maxAllowedHeight = self.pageCollection.bounds.height
        var calculatedWidth = self.pageCollection.bounds.width
        var calculatedHeight = calculatedWidth * aspectRatio
        
        if calculatedHeight > maxAllowedHeight {
            calculatedHeight = maxAllowedHeight
            calculatedWidth = calculatedHeight / aspectRatio
        }
        
        let scaleX = calculatedWidth / width
        let scaleY = calculatedHeight / height
        
        let draggableImageView = DraggableUIView()
        configureDraggableView(draggableImageView, with: getBGElement(height: height, width: width, scaleX: scaleX, scaleY: scaleY), scaleX: scaleX, scaleY: scaleY)
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image
        draggableImageView.originalImage = image
        imageView.contentMode = .scaleAspectFit
        draggableImageView.addSubview(imageView)
        setConstraints(for: imageView, in: draggableImageView)
        
        addGesture(draggableImageView)
        
        self.widthSize = self.widthSize > 0 ? self.widthSize : calculatedWidth
        self.heightSize = self.heightSize > 0 ? self.heightSize : calculatedHeight
        
        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    if let cell = self.pageCollection.cellForItem(at: IndexPath(item: self.pageCount - 1, section: 0)) as? CanvasCell {
                        cell.mainView.addSubview(draggableImageView)
                    } else {
                        self.currentPage?.addSubview(draggableImageView)
                    }
                })
            })
            
            self.pageCollection.reloadData()
            self.pageCollection.layoutIfNeeded()
            self.pageCollection.selectItem(at: IndexPath(item: self.pageCount - 1, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            
            CATransaction.commit()
        }
    }
    
    private func getWaterMarkView() -> DraggableUIView {
        let size = CGSize(width: 150, height: 50)
        let element = UIElement(type: ComponentType.label.rawValue, x: (widthSize / 2), y: ((heightSize - size.height) - 16), width: size.width, height: size.height, movable: nil, isUserInteractionEnabled: nil, alpha: 1, isDuplicatable: nil, isRemovable: nil, cornerRadius: nil, backGroundColor: nil, rotationAngle: 0, text: "appName".localize(), alignment: nil, textColor: nil, fontURL: nil, size: nil, isEditable: nil, contentMode: nil, url: nil, itemNameFontSize: nil, itemDescriptionFontSize: nil, itemValueFontSize: nil, columnWidth: nil, columnSpace: 0, menuData: nil)
        
        let lblView = self.createLabel(with: element, fontFamily: UIFont(name: "RalewayRoman-Bold", size: 18)!, scaleX: 1, scaleY: 1)
        lblView.backgroundColor = UIColor.borderColorC29800
        lblView.cornerRadius = 10
        return lblView
    }
}

// MARK: - Gesture Manager
extension EditorViewController {
    func addGesture(_ view: DraggableUIView) {
        GestureManager.shared.addTapGesture(to: view, target: self, action: #selector(handleTap(_:)))
    }
    
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view as? DraggableUIView else { return }
        self.viewModel.selectedView = view
    }
}

// MARK: - UIColorPicker Delegate
extension EditorViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ picker: UIColorPickerViewController) {
        guard let selectedView = self.viewModel.selectedView else { return }
        switch picker.view.tag {
        case 0:
            setBackgroundColor(picker.selectedColor, view: selectedView)
        case 1:
            if let label = selectedView.subviews.compactMap({ $0 as? UITextView }).first {
                setFontColor(picker.selectedColor, lbl: label)
            } else if let menuBox = selectedView.subviews.compactMap({ $0 as? GridView }).first, let tag = Int(picker.view.stringTag ?? "0"), let type = ResizeOption(rawValue: tag) {
                switch type {
                case .itemName:
                    menuBox.headingColor = picker.selectedColor
                case .itemDescription:
                    menuBox.descriptionColor = picker.selectedColor
                case .itemValue:
                    menuBox.valueColor = picker.selectedColor
                }
            }
        case 2:
            if let shapeView = selectedView.subviews.compactMap({ $0 as? UIImageView}).first {
                self.setTintColor(in: shapeView, tintColor: picker.selectedColor)
            }
        default:
            break
        }
        picker.dismiss(animated: true)
    }
}

// MARK: - Save image to gallery
extension EditorViewController {
    func saveViewAsImageToPhotoLibrary(resolution: ImageResolution) {
        let images = self.getImagesFromTemplate(with: resolution, contentSize: .large)
        for image in images {
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .authorized else {
                    return
                }
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    func getImagesFromTemplate(with resolution: ImageResolution, contentSize: SaveContentSize) -> [UIImage] {
        guard let duplicatedViews = duplicateViewForSaving(contentSize: contentSize) else { return [] }
        
        var availableImages: [UIImage] = []
        let scale = resolution.scale
        
        for duplicatedView in duplicatedViews {
            let size = CGSize(width: duplicatedView.bounds.width * scale, height: duplicatedView.bounds.height * scale)
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            if let context = UIGraphicsGetCurrentContext() {
                context.scaleBy(x: scale, y: scale)
                for subView in duplicatedView.subviews {
                    if let draggableView = subView as? DraggableUIView {
                        context.saveGState()
                        
                        let originalTransform = draggableView.transform
                        
                        let scaleX = sqrt(originalTransform.a * originalTransform.a + originalTransform.c * originalTransform.c)
                        let scaleY = sqrt(originalTransform.b * originalTransform.b + originalTransform.d * originalTransform.d)
                        let translationX = originalTransform.tx
                        let translationY = originalTransform.ty

                        var newTransform = CGAffineTransform.identity
                        newTransform = newTransform.translatedBy(x: translationX, y: translationY)
                        newTransform = newTransform.scaledBy(x: scaleX, y: scaleY)

                        subView.transform = newTransform
                        
                        
                        let centerX = subView.frame.origin.x + (subView.frame.size.width / 2)
                        let centerY = subView.frame.origin.y + (subView.frame.size.height / 2)
                        context.translateBy(x: centerX, y: centerY)
                        
                        
                        let rotationAngle = atan2(originalTransform.b, originalTransform.a)
                        context.rotate(by: rotationAngle)
                        
                        context.translateBy(x: -(subView.frame.size.width / 2), y: -(subView.frame.size.height / 2))
                        
                        if draggableView.isLayered || draggableView.isBlurredView == true {
                            draggableView.drawHierarchy(in: subView.bounds, afterScreenUpdates: true)
                        } else {
                            subView.layer.render(in: context)
                        }
                        context.restoreGState()
                    }
                }
            }
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            duplicatedView.removeFromSuperview()
            
            if let image {
                availableImages.append(image)
            }
        }
        return availableImages
    }
    
    func duplicateViewForSaving(contentSize: SaveContentSize) -> [UIView]? {
        let dynamicUIData = DynamicUIData(superViewWidth: self.widthSize, superViewHeight: self.heightSize, preview_img: "", outputWidth: (Float(self.widthSize) * contentSize.rawValue), outputHeight: (Float(self.heightSize) * contentSize.rawValue), elements: [:])
        
        let size = CGSize(width: CGFloat(dynamicUIData.outputWidth), height: CGFloat(dynamicUIData.outputHeight))
        
        let scaleX = size.width / self.widthSize
        let scaleY = size.height / self.heightSize
        
        var pagesCollection: [UIView] = []
        for index in 0...pageCount - 1 {
            let indexPath = IndexPath(item: index, section: 0)
            self.pageCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.pageCollection.layoutIfNeeded()
            let cell = self.pageCollection.cellForItem(at: indexPath) as? CanvasCell
            var waterMarkView: DraggableUIView?
            if UserManager.shared.currentUserType == .free {
                waterMarkView = self.getWaterMarkView()
                cell?.mainView.addSubview(waterMarkView!)
            }
            let newView = UIView(frame: CGRect(origin: .zero, size: size))
            for subView in cell?.mainView.subviews ?? [] {
                if let draggableView = subView as? DraggableUIView {
                    let clonedSubview = cloneView(draggableView, scaleX: scaleX, scaleY: scaleY)
                    newView.addSubview(clonedSubview)
                }
            }
            pagesCollection.append(newView)
            waterMarkView?.removeFromSuperview()
        }
        
        for subView in pagesCollection {
            self.view.addSubview(subView)
        }
        
        return pagesCollection
    }
    
    private func cloneView(_ view: DraggableUIView, scaleX: CGFloat, scaleY: CGFloat) -> DraggableUIView {
        if view.isLayered {
            return copyLayeredView(draggableView: view, scaleX: scaleX, scaleY: scaleY)
        }
        
        let clonedView = DraggableUIView()
        clonedView.componentType = view.componentType
        clonedView.layer.cornerRadius = view.layer.cornerRadius * min(scaleX, scaleY)
        clonedView.clipsToBounds = true
        clonedView.backgroundColor = view.backgroundColor
        clonedView.alpha = view.alpha
        
        let originalTransform = view.transform
        view.transform = .identity
        clonedView.frame = CGRect(x: view.frame.origin.x * scaleX, y: view.frame.origin.y * scaleY, width: view.frame.width * scaleX, height: view.frame.height * scaleY)
        clonedView.transform = originalTransform
        view.transform = originalTransform
        
        if let blendMode = view.layer.compositingFilter as? String {
            clonedView.layer.compositingFilter = blendMode
        }
        
        for subview in view.subviews {
            let clonedSubview: UIView
            
            if let imageView = subview as? UIImageView {
                let clonedImageView = UIImageView(image: imageView.image)
                clonedImageView.contentMode = imageView.contentMode
                clonedImageView.tintColor = imageView.tintColor
                clonedImageView.backgroundColor = .clear
                clonedSubview = clonedImageView
                clonedSubview.frame = CGRect(origin: .zero, size: clonedView.bounds.size)
                clonedSubview.transform = subview.transform
                
                let blurIntensity = view.blurIntensity
                if blurIntensity > 0 {
                    clonedView.originalImage = imageView.image
                }
                
                if view.layer.shadowOpacity > 0 {
                    clonedView.clipsToBounds = false
                    clonedSubview.layer.shadowColor = view.layer.shadowColor
                    clonedSubview.layer.shadowOpacity = view.layer.shadowOpacity
                    clonedSubview.layer.shadowRadius = view.layer.shadowRadius * scaleX
                    clonedSubview.layer.shadowOffset = CGSize(width: view.layer.shadowOffset.width * scaleX, height: view.layer.shadowOffset.height * scaleY)
                }
                
            } else if let label = subview as? UITextView {
                let clonedLabel = UITextView()
                clonedLabel.text = label.text
                clonedLabel.font = label.font!.withSize(label.font!.pointSize * scaleX)
                clonedLabel.textColor = label.textColor
                clonedLabel.textAlignment = label.textAlignment
                clonedLabel.backgroundColor = .clear
                clonedSubview = clonedLabel
                clonedSubview.frame = CGRect(origin: .zero, size: clonedView.bounds.size)
                clonedSubview.transform = subview.transform
                clonedLabel.centerTextVertically()
            } else if let menuBox = subview as? GridView {
                let gridView = GridView(frame: CGRect(origin: .zero, size: clonedView.bounds.size))
                gridView.menuStyle = menuBox.menuStyle
                gridView.columnWidth = menuBox.columnWidth * scaleX
                
                gridView.itemNameFontSize = menuBox.itemNameFontSize * scaleX
                gridView.itemDescriptionFontSize = menuBox.itemDescriptionFontSize * scaleX
                gridView.itemValueFontSize = menuBox.itemValueFontSize * scaleX
                gridView.columnWidth = menuBox.columnWidth * scaleX
                gridView.columnSpace = menuBox.columnSpace * scaleX
                
                gridView.itemNameFontStyle = menuBox.itemNameFontStyle
                gridView.itemDescriptionFontStyle = menuBox.itemDescriptionFontStyle
                gridView.itemValueFontStyle = menuBox.itemValueFontStyle
                
                gridView.data = menuBox.data
                gridView.headingColor = menuBox.headingColor
                gridView.descriptionColor = menuBox.descriptionColor
                gridView.valueColor = menuBox.valueColor
                clonedSubview = gridView
                clonedSubview.frame = CGRect(origin: .zero, size: clonedView.bounds.size)
                clonedSubview.transform = subview.transform
            } else {
                clonedSubview = UIView(frame: subview.frame)
            }
            clonedView.addSubview(clonedSubview)
        }
        
        return clonedView
    }
    
    func copyLayeredView(draggableView: DraggableUIView, scaleX: CGFloat, scaleY: CGFloat) -> DraggableUIView {
        let clonedView = DraggableUIView()
        clonedView.componentType = draggableView.componentType
        clonedView.layer.cornerRadius = draggableView.layer.cornerRadius * min(scaleX, scaleY)
        clonedView.clipsToBounds = true
        clonedView.backgroundColor = draggableView.backgroundColor
        clonedView.frame = CGRect(x: draggableView.frame.origin.x * scaleX, y: draggableView.frame.origin.y * scaleY, width: draggableView.frame.width * scaleX, height: draggableView.frame.height * scaleY)
        clonedView.transform = view.transform
        clonedView.isRemovable = draggableView.isRemovable
        clonedView.isDuplicatable = draggableView.isDuplicatable
        clonedView.movable = draggableView.movable
        clonedView.isLayered = true
        
        for subView in draggableView.subviews {
            if let imageView = subView as? UIImageView {
                let newImageView = UIImageView()
                newImageView.contentMode = imageView.contentMode
                clonedView.addSubview(newImageView)
                newImageView.image = imageView.image
                newImageView.transform = imageView.transform
                newImageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    newImageView.topAnchor.constraint(equalTo: clonedView.topAnchor),
                    newImageView.bottomAnchor.constraint(equalTo: clonedView.bottomAnchor),
                    newImageView.leadingAnchor.constraint(equalTo: clonedView.leadingAnchor),
                    newImageView.trailingAnchor.constraint(equalTo: clonedView.trailingAnchor)
                ])
            } else if let draggableView = subView as? DraggableUIView {
                for subView in draggableView.subviews {
                    if let imageView = subView as? UIImageView {
                        var frame = imageView.frame
                        frame.size.width.scale(by: scaleX)
                        frame.size.height.scale(by: scaleY)
                        frame.origin.x.scale(by: scaleX)
                        frame.origin.y.scale(by: scaleY)
                        addLayeredImage(in: clonedView, image: imageView.image, frame: frame)
                    }
                }
            }
        }
        
        return clonedView
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            debugPrint("Error saving image to photo library:", error.localizedDescription)
        }
    }
}

// MARK: - Export Json
extension EditorViewController {
    private func getJsonData() -> [String: Any]? {
        let superViewWidth = self.widthSize
        let superViewHeight = self.heightSize
        var elements: [String: Any] = [:]
        
        for index in 0...pageCount - 1 {
            var currentElement: [[String: Any]] = []
            let indexPath = IndexPath(item: index, section: 0)
            self.pageCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
            self.pageCollection.layoutIfNeeded()
            let cell = self.pageCollection.cellForItem(at: indexPath) as? CanvasCell
            for subview in cell?.mainView.subviews ?? [] {
                var elementDict: [String: Any] = [:]
                if let innerSubview = subview as? DraggableUIView {
                    if innerSubview.isUserInteractionEnabled {
                        elementDict["movable"] = innerSubview.movable
                        elementDict["isUserInteractionEnabled"] = innerSubview.isEnabled
                        elementDict["isRemovable"] = innerSubview.isRemovable
                        elementDict["isDuplicatable"] = innerSubview.isDuplicatable
                    } else {
                        elementDict["isUserInteractionEnabled"] = false
                    }
                    let rotationAngle = atan2(innerSubview.transform.b, innerSubview.transform.a)
                    if rotationAngle != 0 {
                        elementDict["rotationAngle"] = rotationAngle
                    }
                    let cornerRadius = Int(innerSubview.layer.cornerRadius)
                    if cornerRadius != 0 {
                        elementDict["cornerRadius"] = cornerRadius
                    }
                    if let colorCode = innerSubview.backgroundColor?.getHexFromColor() {
                        elementDict["backGroundColor"] = colorCode
                    }
                    elementDict["alpha"] = innerSubview.alpha
                    
                    elementDict["x"] = innerSubview.frame.origin.x
                    elementDict["y"] = innerSubview.frame.origin.y
                    elementDict["width"] = innerSubview.frame.width
                    elementDict["height"] = innerSubview.frame.height
                    
                    if let label = innerSubview.subviews.compactMap({ $0 as? UITextView }).first {
                        elementDict["type"] = ComponentType.label.rawValue
                        elementDict["text"] = label.text ?? ""
                        elementDict["fontURL"] = label.font?.fontName
                        elementDict["alignment"] = label.textAlignment.rawValue
                        elementDict["isEditable"] = innerSubview.isEditable
                        elementDict["size"] = label.font?.pointSize
                        if let colorCode = label.textColor?.getHexFromColor(), colorCode != "#000000" {
                            elementDict["textColor"] = colorCode
                        }
                        currentElement.append(elementDict)
                    } else if let imageView = innerSubview.subviews.compactMap({ $0 as? UIImageView }).first {
                        let componentType = ComponentType(rawValue: innerSubview.componentType ?? "")
                        switch componentType {
                        case .image:
                            if let image = innerSubview.originalImage {
                                if let imageName = StorageManager.shared.storeImage(image: image, in: .images) {
                                    elementDict["type"] = innerSubview.componentType
                                    elementDict["contentMode"] = imageView.contentMode.rawValue
                                    elementDict["url"] = imageName
                                    if !innerSubview.isEditable {
                                        elementDict["isEditable"] = innerSubview.isEditable
                                    }
                                    if innerSubview.isLayered {
                                        elementDict["isLayeredImg"] = true
                                    }
                                    if let blendMode = innerSubview.layer.compositingFilter as? String {
                                        elementDict["blendMode"] = blendMode
                                    }
                                    let blurIntensity = innerSubview.blurIntensity
                                    if blurIntensity > 0 {
                                        elementDict["blurAlpha"] = blurIntensity
                                    }
                                    if innerSubview.layer.shadowOpacity > 0 {
                                        elementDict["shadowIntensity"] = innerSubview.layer.shadowOpacity
                                        elementDict["shadowOpacity"] = innerSubview.layer.shadowOpacity
                                        elementDict["shadowRadius"] = innerSubview.layer.shadowRadius
                                        elementDict["shadowOffsetWidth"] = innerSubview.layer.shadowOffset.width
                                        elementDict["shadowOffsetHeight"] = innerSubview.layer.shadowOffset.height
                                    }
                                    if var usersImages = UserDefaults.standard.value(forKey: UserDefaultsKeys.imagesNames) as? [String] {
                                        usersImages.append(imageName)
                                        UserDefaults.standard.setValue(usersImages, forKey: UserDefaultsKeys.imagesNames)
                                    } else {
                                        UserDefaults.standard.setValue([imageName], forKey: UserDefaultsKeys.imagesNames)
                                    }
                                    currentElement.append(elementDict)
                                }
                            }
                        case .shape:
                            if let shapeName = imageView.stringTag {
                                elementDict["type"] = innerSubview.componentType
                                elementDict["url"] = shapeName
                                if !innerSubview.isEditable {
                                    elementDict["isEditable"] = innerSubview.isEditable
                                }
                                if let blendMode = innerSubview.layer.compositingFilter as? String {
                                    elementDict["blendMode"] = blendMode
                                }
                                let blurIntensity = innerSubview.blurIntensity
                                if blurIntensity > 0 {
                                    elementDict["blurAlpha"] = blurIntensity
                                }
                                if innerSubview.layer.shadowOpacity > 0 {
                                    elementDict["shadowIntensity"] = innerSubview.layer.shadowOpacity
                                    elementDict["shadowOpacity"] = innerSubview.layer.shadowOpacity
                                    elementDict["shadowRadius"] = innerSubview.layer.shadowRadius
                                    elementDict["shadowOffsetWidth"] = innerSubview.layer.shadowOffset.width
                                    elementDict["shadowOffsetHeight"] = innerSubview.layer.shadowOffset.height
                                }
                                if let colorCode = imageView.tintColor.getHexFromColor(), colorCode != "#000000" {
                                    elementDict["tintColor"] = colorCode
                                }
                                currentElement.append(elementDict)
                            }
                            break
                        default:
                            break
                        }
                    } else if let gridView = innerSubview.subviews.compactMap({ $0 as? GridView }).first {
                        elementDict["type"] = ComponentType.menuBox.rawValue
                        elementDict["columnWidth"] = gridView.columnWidth
                        if gridView.columnSpace > 0 {
                            elementDict["columnSpace"] = gridView.columnSpace
                        }
                        elementDict["menuStyle"] = gridView.menuStyle.rawValue
                        if gridView.headingColor != .black {
                            elementDict["itemNameTextColor"] = gridView.headingColor.getHexFromColor()
                        }
                        if gridView.descriptionColor != .black {
                            elementDict["itemDescriptionTextColor"] = gridView.descriptionColor.getHexFromColor()
                        }
                        if gridView.valueColor != .black {
                            elementDict["itemValueTextColor"] = gridView.valueColor.getHexFromColor()
                        }
                        var menuData: [[String: Any]] = []
                        for item in gridView.data {
                            menuData.append(["itemName": item.itemName ?? "", "description": item.description ?? "", "values": item.values ?? [:]])
                        }
                        elementDict["menuData"] = menuData
                        elementDict["itemNameFontSize"] = gridView.itemNameFontSize
                        elementDict["itemDescriptionFontSize"] = gridView.itemDescriptionFontSize
                        elementDict["itemValueFontSize"] = gridView.itemValueFontSize
                        if gridView.itemNameFontStyle != UIFont.systemFont(ofSize: gridView.itemNameFontSize) {
                            elementDict["itemNameFontStyle"] = gridView.itemNameFontStyle.fontName
                        }
                        if gridView.itemDescriptionFontStyle != UIFont.systemFont(ofSize: gridView.itemDescriptionFontSize) {
                            elementDict["itemDescriptionFontStyle"] = gridView.itemDescriptionFontStyle.fontName
                        }
                        if gridView.itemValueFontStyle != UIFont.systemFont(ofSize: gridView.itemValueFontSize) {
                            elementDict["itemValueFontStyle"] = gridView.itemValueFontStyle.fontName
                        }
                        currentElement.append(elementDict)
                    }
                }
            }
            elements["\(index)"] = currentElement
        }
        
        let gap:CGFloat = self.pageCount == 1 ? 0 : 5
        let previewWidth = ((CGFloat(pageCount) * (self.widthSize + gap)) - gap)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: previewWidth, height: self.heightSize), false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            for index in 0...pageCount - 1 {
                let indexPath = IndexPath(item: index, section: 0)
                self.pageCollection.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
                self.pageCollection.layoutIfNeeded()
                let cell = self.pageCollection.cellForItem(at: indexPath) as? CanvasCell
                cell?.mainView.layer.borderColor = UIColor.clear.cgColor
                let xPosition = CGFloat(index) * (self.widthSize + gap)
                context.saveGState()
                context.translateBy(x: xPosition, y: 0)
                cell?.mainView.layer.render(in: context)
                context.restoreGState()
            }
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let previewName = StorageManager.shared.storeImage(image: image ?? UIImage(), in: .preview)
        
        return ["superViewWidth": superViewWidth,
                "superViewHeight": superViewHeight,
                "outputWidth": superViewWidth * 10,
                "preview_img": previewName ?? "",
                "outputHeight": superViewHeight * 10,
                "elements": elements]
    }
    
    private func storeJsonPermanently(with name: String, json: [String: Any], success: @escaping () -> Void, failure: @escaping ErrorCallBack, getDocumentData: (([String: Any]) -> Void)? = nil) {
        var newJson = json
        var totalImages = 0
        var previewImgSize: CGSize = CGSize()
        var uploadedImages = 0 {
            didSet {
                if uploadedImages == totalImages {
                    storeAllValue()
                }
            }
        }
        var newElements: [String: [[String: Any]]] = [:]
        
        func storeAllValue() {
            // For current image in json will be deleted
            if isUserIsAdmin && (getDocumentData == nil) {
                if let templateData = self.templateData {
                    for (_, value) in templateData.elements {
                        for element in value {
                            if let componentType = ComponentType(rawValue: element.type), componentType == .image, let imgUrl = element.url {
//                                FirebaseStorageManager.shared.deleteData(from: imgUrl)
                            }
                        }
                    }
                }
            }
            newJson["elements"] = newElements
            var jsonPath: String?
//            FirebaseStorageManager.shared.storeData(type: .jsons,name: name, json: newJson, success: { url in
//                jsonPath = url.absoluteString
//                let projectDetails = ["project_name": name,"json_path": url.absoluteString, "preview_width": previewImgSize.width, "preview_height": previewImgSize.height, "preview_img": newJson["preview_img"] as? String as Any]
//                if let getDocumentData {
//                    getDocumentData(projectDetails)
//                    return
//                }
//                let key = FirestoreManager.shared.getUniqueID(collection: .template)
//                if let projectId = self.projectId, isUserIsAdmin {
//                    FirestoreManager.shared.updateDocument(collection: .template, key: "project_name", value: projectId, data: projectDetails, success: {
//                        debugPrint("Project Updated")
//                        success()
//                    }, failure: { error in
//                        failure(error)
//                    })
//                } else {
//                    FirestoreManager.shared.setDocument(collection: .template, key: key, data: projectDetails, success: {
//                        debugPrint("Project saved")
//                        success()
//                    }, failure: { error in
//                        failure(error)
//                    })
//                }
//                if isUserIsAdmin, let jsonPath {
//                    ApiManager.shared.makeApiCall(type: DynamicUIData.self, url: jsonPath, success: { object in
//                        self.viewModel.dynamicUIData = object
//                        self.templateData = object
//                        self.projectId = name
//                    }, failure: { _ in })
//                }
//            }, failure: { error in
//                failure(error)
//            })
        }
        
        if let previewImageName = UtilsManager.shared.findValueInJson(type: String.self, key: "preview_img", json: json), let image = StorageManager.shared.getImage(fileName: previewImageName) {
            StorageManager.shared.deleteFile(fileName: previewImageName)
            totalImages += 1
            previewImgSize = image.size
            if let imgUrl = self.templateData?.preview_img, let url = URL.init(string: imgUrl), url.isHosted(), isUserIsAdmin {
//                FirebaseStorageManager.shared.updateImage(for: imgUrl, img: image, success: {
//                    newJson["preview_img"] = imgUrl
//                    uploadedImages += 1
//                }, failure: { error in
//                    debugPrint(error)
//                })
            } else {
//                FirebaseStorageManager.shared.storeData(type: .previews, image: image, success: { imgUrl in
//                    newJson["preview_img"] = imgUrl.absoluteString
//                    uploadedImages += 1
//                }, failure: { error in
//                    debugPrint(error)
//                })
            }
        }
        
        if let elementsJson = UtilsManager.shared.findValueInJson(type: [String: [[String: Any]]].self, key: "elements", json: json) {
            newElements = elementsJson
            for mainIndex in 0...pageCount - 1 {
                if let elementArray = elementsJson["\(mainIndex)"] {
                    for (index, element) in elementArray.enumerated() {
                        if element["type"] as? String == ComponentType.image.rawValue, let imageName = element["url"] as? String, let image = StorageManager.shared.getImage(fileName: imageName) {
                            StorageManager.shared.deleteFile(fileName: imageName)
                            totalImages += 1
//                            FirebaseStorageManager.shared.storeData(type: .images, image: image, success: { imgUrl in
//                                newElements["\(mainIndex)"]?[index]["url"] = imgUrl.absoluteString
//                                uploadedImages += 1
//                            }, failure: { error in
//                                debugPrint(error)
//                            })
                        }
                    }
                }
            }
        }
    }
}

// MARK: - CollectionView Delegate and DataSource
extension EditorViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == pageCollection {
            return pageCount
        } else {
            return componentTypes.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == pageCollection {
            var uniqueIdentifier = "cell-\(indexPath.item)"
            if let id = self.uniqueIdentifierIds[indexPath.item] {
                uniqueIdentifier = "cell-\(id)"
            } else if var maxId = self.uniqueIdentifierIds.values.max() {
                if let maxDeleted = self.deletedIdentifierValue.max() {
                    maxId = max(maxId, maxDeleted)
                }
                let newId = (maxId + 1)
                uniqueIdentifier = "cell-\(newId)"
                self.uniqueIdentifierIds[indexPath.item] = newId
            }  else {
                self.uniqueIdentifierIds[indexPath.item] = indexPath.item
            }
            collectionView.register(UINib(nibName: "CanvasCell", bundle: packageBundle), forCellWithReuseIdentifier: uniqueIdentifier)
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: uniqueIdentifier, for: indexPath) as! CanvasCell
            cell.mainView.clipsToBounds = true
            cell.mainViewWidthAnchor.constant = self.widthSize
            cell.mainViewHeightAnchor.constant = self.heightSize
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: OptionCell.self), for: indexPath) as! OptionCell
            cell.optionImage.image = UIImage(named: componentTypes[indexPath.item].icon)
            cell.optionLabel.text = componentTypes[indexPath.item].localName
            cell.isSeparatorVisible = indexPath.item != componentTypes.count - 1 ? true : false
            cell.isPremiumFeature = componentTypes[indexPath.item].isPremiumFeature
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView != pageCollection else { return }
        if componentTypes[indexPath.item].isPremiumFeature && UserManager.shared.currentUserType == .free {
            self.showPremiumFeatureAlert()
            return
        }
        switch componentTypes[indexPath.item] {
        case .label:
            self.addLabelView()
        case .image:
            self.presentImagePickerOptions()
        case .menuBox:
            self.presentMenuStylePicker()
        case .shape:
            self.presentShapeView(forAdding: true)
        case .page:
            self.presentAddPageOptions()
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if scrollView == self.pageCollection {
            DispatchQueue.main.async {
                if let cell = self.pageCollection.visibleCells.first as? CanvasCell {
                    cell.isSelected = true
                }
                let index = self.pageCollection.indexPathsForVisibleItems.first
                self.pageControl.currentPage = index?.item ?? 0
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.pageCollection {
            currentPageIndex = Int(ceil(scrollView.contentOffset.x / pageCollection.bounds.width))
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.pageCollection {
            DispatchQueue.main.async {
                if let cell = self.pageCollection.visibleCells.first as? CanvasCell {
                    cell.isSelected = true
                }
                let index = self.pageCollection.indexPathsForVisibleItems.first
                self.pageControl.currentPage = index?.item ?? 0
            }
        }
    }
}
