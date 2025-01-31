//
//  MenuStyleSelection.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

import UIKit

class MenuStyleSelection: UIViewController {

    @IBOutlet private weak var styleCollection: UICollectionView!
    
    private var menuStyles: [MenuStyle] = MenuStyle.allCases
    
    var selectedMenuStyle: ((MenuStyle) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        doInitSetup()
    }
    
    private func doInitSetup() {
        self.styleCollection.registerNib(for: MenuStyleCell.self)
    }
}

// MARK: - Action Methods
extension MenuStyleSelection {
    @IBAction private func cancelBtnTapped(_ sender: UIControl) {
        self.dismiss(animated: true)
    }
    
    @IBAction private func infoBtnTapped(_ sender: UIControl) {
        
    }
}

// MARK: - CollectionView Delegate
extension MenuStyleSelection: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menuStyles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: MenuStyleCell.self), for: indexPath) as! MenuStyleCell
        cell.styleImg.image = UIImage(named: menuStyles[indexPath.item].iconName)
        cell.isPremium = menuStyles[indexPath.item].isPremium
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedMenuStyle?(self.menuStyles[indexPath.item])
        self.dismiss(animated: true)
    }
}
