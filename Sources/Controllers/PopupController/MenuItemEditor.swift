//
//  MenuItemEditor.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import UIKit

class MenuItemEditor: UIViewController {

    @IBOutlet private weak var mainView: UIView!
    @IBOutlet private weak var costTbl: UITableView!
    @IBOutlet private weak var addBtn: UIControl!
    @IBOutlet private weak var costTblHeightAnchor: NSLayoutConstraint!
    @IBOutlet private weak var itemNameLbl: UILabel!
    @IBOutlet private weak var itemNameTxt: UITextView!
    @IBOutlet private weak var itemDescriptionTxt: UITextView!
    @IBOutlet private weak var saveBtn: UIControl!
    @IBOutlet private weak var mainViewLeadingAnchor: NSLayoutConstraint!
    @IBOutlet private weak var mainViewTrailingAnchor: NSLayoutConstraint!
    
    private var totalCostField: Int = 1
    private var maxCostField: Int = 3
    private var itemCosts: [Int: String] = [:]
    private var is2TxtMenu: Bool = false
    
    var menuStyle: MenuStyle = .type1
    var itemDetails: MenuItemDetails?
    var updatedItem: ((MenuItemDetails) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doInitSetup()
    }
    
    private func doInitSetup() {
        self.saveBtn.backgroundColor = Theme.primaryButtonColor
        for subView in self.mainView.subviews {
            if let lbl = subView as? UILabel {
                lbl.textColor = Theme.primaryTextColor
            }
        }
        self.costTbl.registerNib(for: ItemCostCell.self)
        
        if menuStyle == .type11 || menuStyle == .type7 || menuStyle == .type8 {
            self.is2TxtMenu = true
            self.totalCostField = 2
            self.maxCostField = 2
            self.costTblHeightAnchor.constant = CGFloat((self.totalCostField * 48) + ((self.totalCostField - 1) * 16))
            self.addBtn.isHidden = true
        } else if let values = itemDetails?.values?.count, values > 1 {
            self.totalCostField = values
            self.costTblHeightAnchor.constant = CGFloat((self.totalCostField * 48) + ((self.totalCostField - 1) * 16))
//            self.view.layoutIfNeeded()
        }
        
        for index in 0...maxCostField - 1 {
            self.itemCosts[index] = ""
        }
        
        if let itemDetails {
            if let itemName = itemDetails.itemName {
                self.itemNameLbl.text = itemName
                self.itemNameTxt.text = itemName
                self.itemNameTxt.textColor = .black
            }
            if let itemDescription = itemDetails.description {
                self.itemDescriptionTxt.text = itemDescription
                self.itemDescriptionTxt.textColor = .black
            }
            if let values = itemDetails.values {
                for (key, value) in values {
                    self.itemCosts[(Int(key) ?? -1) - 1] = value
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if isIpad {
            self.mainViewLeadingAnchor.constant = self.view.frame.width / 4
            self.mainViewTrailingAnchor.constant = self.view.frame.width / 4
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.mainView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        self.view.alpha = 0
        UIView.animate(withDuration: 0.33, animations: {
            self.view.alpha = 1
            self.mainView.transform = .identity
        })
    }
}

// MARK: - Private Methods
extension MenuItemEditor {
    private func removeValueFromJson(at index: Int) {
        self.itemCosts.removeValue(forKey: index)
        for index in index...totalCostField {
            if let value = self.itemCosts[index + 1] {
                self.itemCosts[index] = value
                self.itemCosts.removeValue(forKey: index + 1)
            }
        }
    }
    
    private func getUpdatedItem() -> MenuItemDetails {
        var values = [String: String]()
        for (key, value) in self.itemCosts {
            if value != "" {
                values["\(key + 1)"] = value
            }
        }
        var itemName = self.itemNameTxt.text
        if itemName == self.itemNameTxt.placeHolder {
            itemName = ""
        }
        var itemDescription = self.itemDescriptionTxt.text
        if itemDescription == self.itemDescriptionTxt.placeHolder {
            itemDescription = ""
        }
        return MenuItemDetails(itemName: itemName, description: itemDescription, values: values)
    }
}

// MARK: - Action Methods
extension MenuItemEditor {
    @IBAction private func closeBtnTapped(_ sender: UIControl) {
        UIView.animate(withDuration: 0.33, animations: {
            self.view.alpha = 0
            self.mainView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            self.dismiss(animated: false)
        })
    }
    
    @IBAction private func saveBtnTaped(_ sender: UIControl) {
        self.updatedItem?(self.getUpdatedItem())
        UIView.animate(withDuration: 0.33, animations: {
            self.view.alpha = 0
            self.mainView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            self.dismiss(animated: false)
        })
    }
    
    @IBAction private func addCostBtnTapped(_ sender: UIControl) {
        guard self.totalCostField != self.maxCostField else { return }
        self.totalCostField += is2TxtMenu ? 2 : 1
        UIView.animate(withDuration: 0.33, animations: {
            self.costTblHeightAnchor.constant = CGFloat((self.totalCostField * 48) + ((self.totalCostField - 1) * 16))
            self.view.layoutIfNeeded()
        })
        self.costTbl.performBatchUpdates({
            if self.is2TxtMenu {
                self.costTbl.insertRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: .left)
            } else {
                self.costTbl.insertRows(at: [IndexPath(row: 0, section: 0)], with: .left)
            }
        }, completion: { _ in
            self.costTbl.reloadData()
        })
    }
    
    @objc private func deleteCell(_ gesture: UISwipeGestureRecognizer) {
        if let cell = gesture.view as? UITableViewCell,
           let indexPath = self.costTbl.indexPath(for: cell) {
            self.totalCostField -= is2TxtMenu ? 2 : 1
            UIView.animate(withDuration: 0.33, animations: {
                self.costTblHeightAnchor.constant = CGFloat((self.totalCostField * 48) + ((self.totalCostField - 1) * 16))
                self.view.layoutIfNeeded()
            })
            if is2TxtMenu {
                self.itemCosts.removeValue(forKey: 0)
                self.itemCosts.removeValue(forKey: 1)
                self.costTbl.performBatchUpdates({
                    self.costTbl.deleteRows(at: [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)], with: .right)
                }, completion: { _ in
                    self.costTbl.reloadData()
                })
            } else {
                self.removeValueFromJson(at: indexPath.row)
                self.costTbl.performBatchUpdates({
                    self.costTbl.deleteRows(at: [IndexPath(row: indexPath.row, section: 0)], with: .right)
                }, completion: { _ in
                    self.costTbl.reloadData()
                })
            }
        }
    }
}

// MARK: - TextView Delegate
extension MenuItemEditor: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView.text == textView.placeHolder {
            self.itemCosts[textView.tag] = ""
        } else {
            self.itemCosts[textView.tag] = textView.text
        }
    }
}

// MARK: - TableView Delegate
extension MenuItemEditor: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalCostField
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: ItemCostCell.self), for: indexPath) as! ItemCostCell
        if self.itemCosts[indexPath.row] != "" {
            cell.costTxt.text = self.itemCosts[indexPath.row]
            cell.costTxt.textColor = .black
        } else {
            cell.costTxt.text = ""
            cell.costTxt.placeHolder = cell.costTxt.placeHolder
            cell.costTxt.textColor = .lightGray
        }
        cell.costTxt.tag = indexPath.row
        cell.costTxt.delegate = self
    
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(deleteCell(_:)))
        swipeGesture.direction = .right
        cell.addGestureRecognizer(swipeGesture)
        return cell
    }
}
