//
//  NibRegister.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

import UIKit

extension UITableView {
    func registerNib<T: UITableViewCell>(for cellType: T.Type, bundle: Bundle? = nil) {
        let nib = UINib(nibName: String(describing: cellType), bundle: packageBundle)
        self.register(nib, forCellReuseIdentifier: String(describing: cellType))
    }
}

extension UICollectionView {
    func registerNib<T: UICollectionViewCell>(for cellType: T.Type, bundle: Bundle? = nil) {
        let nib = UINib(nibName: String(describing: cellType), bundle: packageBundle)
        self.register(nib, forCellWithReuseIdentifier: String(describing: cellType))
    }
}
