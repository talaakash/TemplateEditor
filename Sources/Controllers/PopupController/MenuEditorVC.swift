//
//  MenuEditorVC.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import UIKit

class MenuEditorVC: UIViewController {

    @IBOutlet private weak var menuItemsTbl: UITableView!
    
    var menuStyle: MenuStyle = .type1
    var menuData: [MenuItemDetails] = []
    var updatedData: (([MenuItemDetails]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doInitSetup()
    }
    
    private func doInitSetup() {
        self.menuItemsTbl.registerNib(for: MenuItemEditorCell.self)
        self.menuItemsTbl.dragDelegate = self
    }
}

// MARK: - Private Methods
extension MenuEditorVC {
    
}

// MARK: - Action Methods
extension MenuEditorVC {
    @IBAction private func backBtnTapped(_ sender: UIControl) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction private func saveBtnTapped(_ sender: UIControl) {
        self.updatedData?(menuData)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func addItemBtnTapped(_ sender: UIControl) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuItemEditor") as! MenuItemEditor
        vc.menuStyle = self.menuStyle
        vc.modalPresentationStyle = .overCurrentContext
        vc.updatedItem = { newItem in
            self.menuData.append(newItem)
            self.menuItemsTbl.reloadData()
        }
        self.present(vc, animated: false)
    }
    
    @objc func editBtnTapped(_ gesture: UITapGestureRecognizer) {
        guard let index = gesture.view?.tag else { return }
        let item = menuData[index]
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "MenuItemEditor") as! MenuItemEditor
        vc.modalPresentationStyle = .overCurrentContext
        vc.itemDetails = item
        vc.menuStyle = self.menuStyle
        vc.updatedItem = { newItem in
            self.menuData[index] = newItem
            self.menuItemsTbl.reloadData()
        }
        self.present(vc, animated: false)
    }
}

// MARK: - TableView Delegate
extension MenuEditorVC: UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MenuItemEditorCell.self), for: indexPath) as! MenuItemEditorCell
        
        let item = menuData[indexPath.row]
        for subView in cell.containerView.subviews {
            subView.removeFromSuperview()
        }
        cell.editBtn.tag = indexPath.row
        GestureManager.shared.addTapGesture(to: cell.editBtn, target: self, action: #selector(editBtnTapped(_:)))
        
        if let menuItem = UINib(nibName: "MenuItem", bundle: packageBundle).instantiate(withOwner: nil).first as? MenuItem {
            menuItem.columnWidth = 30
            menuItem.noOfColumns = menuData.max(by: { $0.values?.count ?? 0 < $1.values?.count ?? 0 })?.values?.count ?? 0
            menuItem.data = item
            cell.containerView.addSubview(menuItem)
            menuItem.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                menuItem.leadingAnchor.constraint(equalTo: cell.containerView.leadingAnchor),
                menuItem.trailingAnchor.constraint(equalTo: cell.containerView.trailingAnchor),
                menuItem.topAnchor.constraint(equalTo: cell.containerView.topAnchor),
                menuItem.bottomAnchor.constraint(equalTo: cell.containerView.bottomAnchor)
            ])
        }
        
        return cell
    }
    
    // Rearrange row
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = menuData[sourceIndexPath.row]
        menuData.remove(at: sourceIndexPath.row)
        menuData.insert(movedObject, at: destinationIndexPath.row)
        tableView.reloadData()
    }
    
    // Remove row
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        menuData.remove(at: indexPath.row)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
}
