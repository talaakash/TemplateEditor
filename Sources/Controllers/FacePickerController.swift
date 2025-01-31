//
//  FacePickerController.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import UIKit

class FacePickerController: UIViewController {

    @IBOutlet private weak var fontFacesTbl: UITableView!
    @IBOutlet private weak var searchBar: UITextField!
    
    private var availableFaces: [String] = []
    
    var faces: [String]?
    var selectedFontDescriptor: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fontFacesTbl.register(UINib(nibName: "FontStyleCell", bundle: nil), forCellReuseIdentifier: "FontStyleCell")
        self.fontFacesTbl.showsHorizontalScrollIndicator = false
        self.fontFacesTbl.showsVerticalScrollIndicator = false
        self.searchBar.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.filterFaces(with: "")
    }
}

// MARK: - Private methods
extension FacePickerController {
    private func filterFaces(with text: String) {
        if text == "" {
            self.availableFaces = self.faces ?? []
        } else {
            self.availableFaces = self.faces?.compactMap({ face in
                face.lowercased().contains(text.lowercased()) ? face : nil
            }) ?? []
        }
        self.fontFacesTbl.reloadData()
    }
}

// MARK: - Action Methods
extension FacePickerController {
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let text = textField.text else { return }
        self.filterFaces(with: text)
    }
    
    @IBAction private func backBtnTapped(_ sender: UIControl) {
        self.dismiss(animated: false)
    }
}

extension FacePickerController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.availableFaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FontStyleCell", for: indexPath) as! FontStyleCell
        let name = self.availableFaces[indexPath.row]
        if let fontStyle = UIFont(name: name, size: 16) {
            cell.styleName.font = fontStyle
        }
        if let face = name.split(separator: "-").last {
            cell.styleName.text = "\(face)"
        } else {
            cell.styleName.text = name
        }
        cell.hasFaces = false
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let faceName = self.availableFaces[indexPath.row]
        self.dismiss(animated: false)
        self.selectedFontDescriptor?(faceName)
    }
}
