//
//  SeparatorStackView.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//


import Foundation
import UIKit

public class SeparatorStackView: UIStackView {

    public var separatorColor: UIColor = .lightGray {
        didSet {
            updateSeparators()
        }
    }
    
    public var separatorWidth: CGFloat = 1.0 {
        didSet {
            updateSeparators()
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        insertSeparators()
    }
    
    public override func addArrangedSubview(_ view: UIView) {
        super.addArrangedSubview(view)
        insertSeparators()
    }
    
    public override func insertArrangedSubview(_ view: UIView, at stackIndex: Int) {
        super.insertArrangedSubview(view, at: stackIndex)
        insertSeparators()
    }
    
    public override func removeArrangedSubview(_ view: UIView) {
        super.removeArrangedSubview(view)
        insertSeparators()
    }
    
    private func insertSeparators() {
        // Remove existing separators
        for view in arrangedSubviews where view.tag == 999 {
            view.removeFromSuperview()
        }
        
        // Insert separators between each arranged subview, except the last one
        if arrangedSubviews.count >= 2 {
            for index in 1..<arrangedSubviews.count {
                let separator = createSeparator()
                super.insertArrangedSubview(separator, at: index * 2 - 1)
                configureSeparatorConstraints(separator)
            }
        }
    }
    
    private func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = separatorColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.tag = 999
        return separator
    }
    
    private func configureSeparatorConstraints(_ separator: UIView) {
        if axis == .horizontal {
            separator.widthAnchor.constraint(equalToConstant: separatorWidth).isActive = true
            separator.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        } else {
            separator.heightAnchor.constraint(equalToConstant: separatorWidth).isActive = true
            separator.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        }
    }
    
    private func updateSeparators() {
        for view in arrangedSubviews where view.tag == 999 {
            view.backgroundColor = separatorColor
            configureSeparatorConstraints(view)
        }
    }
}
