//
//  FontPickerController.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

import UIKit

class FontStyle {
    let name: String
    let faceNames: [String]
    let hasFaces: Bool
    
    init(name: String, faceNames: [String], hasFaces: Bool) {
        self.name = name
        self.faceNames = faceNames
        self.hasFaces = hasFaces
    }
}

class FontGroup {
    var familyNames: [FontStyle]
    
    init(familyNames: [FontStyle]) {
        self.familyNames = familyNames
    }
}

class FontPickerController: UIViewController {

    @IBOutlet private weak var fontStylesTbl: UITableView!
    @IBOutlet private weak var searchBar: UITextField!
    
    var selectedFontDescriptor: ((String) -> Void)?
    
    private let allFonts: [FontStyle] = UIFont.familyNames.compactMap({ name in
        let facesName = UIFont.fontNames(forFamilyName: name)
        return FontStyle(name: name, faceNames: facesName, hasFaces: facesName.count > 1)
    })
    private var allGroups: [FontGroup] = []
    private var availableGroups: [FontGroup] = []
    private var sectionNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doInitSetup()
    }
    
    private func doInitSetup() {
        self.fontStylesTbl.registerNib(for: FontStyleCell.self)
        self.fontStylesTbl.showsHorizontalScrollIndicator = false
        self.fontStylesTbl.showsVerticalScrollIndicator = false
        self.searchBar.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.allGroups = Dictionary(grouping: allFonts) { String($0.name.prefix(1)) }
            .sorted{ $0.key < $1.key }
            .map { FontGroup(familyNames: $0.value) }
        
        self.filterGroup(with: "")
    }
}

// MARK: - Action Methods
extension FontPickerController {
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        self.filterGroup(with: text)
    }
    
    @IBAction private func closeBtnTapped(_ sender: UIControl) {
        self.dismiss(animated: true)
    }
}

// MARK: - Private methods
extension FontPickerController {
    private func filterGroup(with text: String) {
        if text != "" {
            self.availableGroups = self.allGroups.compactMap { group in
                let filteredFamilyNames = group.familyNames.filter { fontStyle in
                    fontStyle.name.lowercased().contains(text.lowercased())
                }
                return filteredFamilyNames.isEmpty ? nil : FontGroup(familyNames: filteredFamilyNames)
            }
        } else {
            self.availableGroups = self.allGroups
        }
        self.sectionNames = self.availableGroups.compactMap { fontFamilies in
            fontFamilies.familyNames.first?.name.prefix(1).uppercased()
        }
        self.fontStylesTbl.reloadData()
    }
}

// MARK: - TableView delegate and datasource
extension FontPickerController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.availableGroups.count
    }
//    MARK: This is for side index for scroll
//    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
//        return self.availableGroups.compactMap { fontFamilies in
//            fontFamilies.familyNames.first?.name.prefix(1).uppercased()
//        }
//    }
    
//    MARK: Default header
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section <= (self.sectionNames.count - 1) {
//            return self.sectionNames[section]
//        }
//        return nil
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section <= (self.sectionNames.count - 1) {
            let headerView = UIView()
            headerView.backgroundColor = .clear
            
            let label = UILabel()
            label.text = self.sectionNames[section]
            label.textColor = .black
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.frame = CGRect(x: 2, y: 5, width: tableView.frame.width - 32, height: 25)
            
            headerView.addSubview(label)
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availableGroups[section].familyNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: FontStyleCell.self), for: indexPath) as! FontStyleCell
        let font = self.availableGroups[indexPath.section].familyNames[indexPath.row]
        if let faceName = font.faceNames.first {
            cell.styleName.font = UIFont.init(name: faceName, size: 16)
        }
        cell.styleName.text = font.name
        cell.hasFaces = font.hasFaces
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fontStyle = self.availableGroups[indexPath.section].familyNames[indexPath.row]
        if fontStyle.hasFaces {
            let vc = self.storyboard?.instantiateViewController(identifier: "FacePickerController") as! FacePickerController
            vc.faces = fontStyle.faceNames
            vc.selectedFontDescriptor = { [weak self] face in
                self?.selectedFontDescriptor?(face)
                self?.dismiss(animated: true)
            }
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: false)
        } else {
            self.selectedFontDescriptor?(fontStyle.faceNames.first!)
            self.dismiss(animated: true)
        }
    }
}
