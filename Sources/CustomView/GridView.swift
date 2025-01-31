//
//  GridView.swift
//  Pods
//
//  Created by Akash Tala on 31/01/25.
//

import UIKit

extension Notification.Name {
    static let columnWidthChange = Notification.Name("columnWidthChange")
}

class GridView: UIStackView {
    
    private var maxColumns: Int = 0
    
    var columnWidth: CGFloat = .zero {
        didSet {
            for subView in self.subviews {
                if let menuItem = subView as? ItemView {
                    menuItem.columnWidth = self.columnWidth
                }
            }
        }
    }
    var columnSpace: CGFloat = .zero {
        didSet {
            for subView in self.subviews {
                if let menuItem = subView as? ItemView {
                    menuItem.columnSpace = self.columnSpace
                }
            }
        }
    }
    var menuStyle: MenuStyle = .type1
    var data: [MenuItemDetails] = [] {
        didSet {
            for subView in self.subviews {
                subView.removeFromSuperview()
            }
            self.maxColumns = data.max(by: { $0.values?.count ?? 0 < $1.values?.count ?? 0 })?.values?.count ?? 0
            self.addDataInView()
        }
    }
    
    var headingColor: UIColor = .black {
        didSet {
            for subView in self.subviews {
                if let menuItem = subView as? ItemView {
                    menuItem.headingFontColor = headingColor
                }
            }
        }
    }
    
    var descriptionColor: UIColor = .black {
        didSet {
            for subView in self.subviews {
                if let menuItem = subView as? ItemView {
                    menuItem.descriptionFontColor = descriptionColor
                }
            }
        }
    }
    
    var valueColor: UIColor = .black {
        didSet {
            for subView in self.subviews {
                if let menuItem = subView as? ItemView {
                    menuItem.valueFontColor = valueColor
                }
            }
        }
    }
    
    var itemNameFontSize: CGFloat = 19 {
        didSet {
            for subView in self.subviews {
                if let itemView = subView as? ItemView {
                    itemView.itemNameFontSize = self.itemNameFontSize
                }
            }
        }
    }
    var itemDescriptionFontSize: CGFloat = 17 {
        didSet {
            for subView in self.subviews {
                if let itemView = subView as? ItemView {
                    itemView.itemDescriptionFontSize = self.itemDescriptionFontSize
                }
            }
        }
    }
    var itemValueFontSize: CGFloat = 17 {
        didSet {
            for subView in self.subviews {
                if let itemView = subView as? ItemView {
                    itemView.itemValueFontSize = self.itemValueFontSize
                }
            }
        }
    }
    
    var itemNameFontStyle: UIFont = UIFont.systemFont(ofSize: 19) {
        didSet {
            for subView in self.subviews {
                if let itemView = subView as? ItemView {
                    itemView.itemNameFontStyle = self.itemNameFontStyle
                }
            }
        }
    }
    var itemDescriptionFontStyle: UIFont = UIFont.systemFont(ofSize: 17) {
        didSet {
            for subView in self.subviews {
                if let itemView = subView as? ItemView {
                    itemView.itemDescriptionFontStyle = self.itemDescriptionFontStyle
                }
            }
        }
    }
    var itemValueFontStyle: UIFont = UIFont.systemFont(ofSize: 17) {
        didSet {
            for subView in self.subviews {
                if let itemView = subView as? ItemView {
                    itemView.itemValueFontStyle = self.itemValueFontStyle
                }
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.doInitialSetup()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func doInitialSetup() {
        self.axis = .vertical
        self.distribution = .equalSpacing
        NotificationCenter.default.addObserver(self, selector: #selector(handleColumnWidthChange(_:)), name: .columnWidthChange, object: nil)
    }
}

// MARK: - Private methods
extension GridView {
    @objc private func handleColumnWidthChange(_ notification: NSNotification) {
        if let newWidth = notification.userInfo?["columnWidth"] as? CGFloat {
            self.columnWidth = newWidth
        }
    }
    
    private func addType1Menu(with item: MenuItemDetails) {
        if let menuItem = Bundle.main.loadNibNamed("Type1Menu", owner: nil, options: nil)?.first as? Type1Menu {
            menuItem.columnWidth = self.columnWidth
            menuItem.noOfColumns = self.maxColumns
            menuItem.headingFontColor = self.headingColor
            menuItem.descriptionFontColor = self.descriptionColor
            menuItem.valueFontColor = self.valueColor
            menuItem.itemNameFontSize = self.itemNameFontSize
            menuItem.itemDescriptionFontSize = self.itemDescriptionFontSize
            menuItem.itemValueFontSize = self.itemValueFontSize
            menuItem.itemNameFontStyle = self.itemNameFontStyle
            menuItem.itemDescriptionFontStyle = self.itemDescriptionFontStyle
            menuItem.itemValueFontStyle = self.itemValueFontStyle
            menuItem.data = item
            self.addArrangedSubview(menuItem)
        }
    }
    
    private func addType2Menu(with item: MenuItemDetails) {
        if let menuItem = Bundle.main.loadNibNamed("Type2Menu", owner: nil, options: nil)?.first as? Type2Menu {
            menuItem.columnWidth = self.columnWidth
            menuItem.noOfColumns = self.maxColumns
            menuItem.headingFontColor = self.headingColor
            menuItem.descriptionFontColor = self.descriptionColor
            menuItem.valueFontColor = self.valueColor
            menuItem.itemNameFontSize = self.itemNameFontSize
            menuItem.itemDescriptionFontSize = self.itemDescriptionFontSize
            menuItem.itemValueFontSize = self.itemValueFontSize
            menuItem.itemNameFontStyle = self.itemNameFontStyle
            menuItem.itemDescriptionFontStyle = self.itemDescriptionFontStyle
            menuItem.itemValueFontStyle = self.itemValueFontStyle
            menuItem.data = item
            self.addArrangedSubview(menuItem)
        }
    }
    
    private func addType3Menu(with item: MenuItemDetails) {
        if let menuItem = Bundle.main.loadNibNamed("Type3Menu", owner: nil, options: nil)?.first as? Type3Menu {
            menuItem.columnWidth = self.columnWidth
            menuItem.noOfColumns = self.maxColumns
            menuItem.headingFontColor = self.headingColor
            menuItem.descriptionFontColor = self.descriptionColor
            menuItem.valueFontColor = self.valueColor
            menuItem.itemNameFontSize = self.itemNameFontSize
            menuItem.itemDescriptionFontSize = self.itemDescriptionFontSize
            menuItem.itemValueFontSize = self.itemValueFontSize
            menuItem.itemNameFontStyle = self.itemNameFontStyle
            menuItem.itemDescriptionFontStyle = self.itemDescriptionFontStyle
            menuItem.itemValueFontStyle = self.itemValueFontStyle
            menuItem.data = item
            self.addArrangedSubview(menuItem)
        }
    }
    
    private func addType4Menu(with item: MenuItemDetails) {
        if let menuItem = Bundle.main.loadNibNamed("Type4Menu", owner: nil, options: nil)?.first as? Type4Menu {
            menuItem.headingFontColor = self.headingColor
            menuItem.descriptionFontColor = self.descriptionColor
            menuItem.valueFontColor = self.valueColor
            menuItem.itemNameFontSize = self.itemNameFontSize
            menuItem.itemDescriptionFontSize = self.itemDescriptionFontSize
            menuItem.itemValueFontSize = self.itemValueFontSize
            menuItem.itemNameFontStyle = self.itemNameFontStyle
            menuItem.itemDescriptionFontStyle = self.itemDescriptionFontStyle
            menuItem.itemValueFontStyle = self.itemValueFontStyle
            menuItem.data = item
            self.addArrangedSubview(menuItem)
        }
    }
    
    private func addType5Menu(with item: MenuItemDetails) {
        if let menuItem = Bundle.main.loadNibNamed("Type5Menu", owner: nil, options: nil)?.first as? Type5Menu {
            menuItem.columnWidth = self.columnWidth
            menuItem.headingFontColor = self.headingColor
            menuItem.descriptionFontColor = self.descriptionColor
            menuItem.valueFontColor = self.valueColor
            menuItem.itemNameFontSize = self.itemNameFontSize
            menuItem.itemDescriptionFontSize = self.itemDescriptionFontSize
            menuItem.itemValueFontSize = self.itemValueFontSize
            menuItem.itemNameFontStyle = self.itemNameFontStyle
            menuItem.itemDescriptionFontStyle = self.itemDescriptionFontStyle
            menuItem.itemValueFontStyle = self.itemValueFontStyle
            menuItem.data = item
            self.addArrangedSubview(menuItem)
        }
    }
    
    private func addType6Menu(with item: MenuItemDetails) {
        if let menuItem = Bundle.main.loadNibNamed("Type6Menu", owner: nil, options: nil)?.first as? Type6Menu {
            menuItem.columnWidth = self.columnWidth
            menuItem.noOfColumns = self.maxColumns
            menuItem.headingFontColor = self.headingColor
            menuItem.descriptionFontColor = self.descriptionColor
            menuItem.valueFontColor = self.valueColor
            menuItem.itemNameFontSize = self.itemNameFontSize
            menuItem.itemDescriptionFontSize = self.itemDescriptionFontSize
            menuItem.itemValueFontSize = self.itemValueFontSize
            menuItem.itemNameFontStyle = self.itemNameFontStyle
            menuItem.itemDescriptionFontStyle = self.itemDescriptionFontStyle
            menuItem.itemValueFontStyle = self.itemValueFontStyle
            menuItem.data = item
            self.addArrangedSubview(menuItem)
        }
    }
    
    private func addType7Menu(with item: MenuItemDetails) {
        if let menuItem = Bundle.main.loadNibNamed("Type7Menu", owner: nil, options: nil)?.first as? Type7Menu {
            menuItem.columnWidth = self.columnWidth
            menuItem.headingFontColor = self.headingColor
            menuItem.descriptionFontColor = self.descriptionColor
            menuItem.valueFontColor = self.valueColor
            menuItem.itemNameFontSize = self.itemNameFontSize
            menuItem.itemDescriptionFontSize = self.itemDescriptionFontSize
            menuItem.itemValueFontSize = self.itemValueFontSize
            menuItem.itemNameFontStyle = self.itemNameFontStyle
            menuItem.itemDescriptionFontStyle = self.itemDescriptionFontStyle
            menuItem.itemValueFontStyle = self.itemValueFontStyle
            menuItem.data = item
            self.addArrangedSubview(menuItem)
        }
    }
    
    private func addType8Menu(with item: MenuItemDetails) {
        if let menuItem = Bundle.main.loadNibNamed("Type8Menu", owner: nil, options: nil)?.first as? Type8Menu {
            menuItem.columnWidth = self.columnWidth
            menuItem.headingFontColor = self.headingColor
            menuItem.descriptionFontColor = self.descriptionColor
            menuItem.valueFontColor = self.valueColor
            menuItem.itemNameFontSize = self.itemNameFontSize
            menuItem.itemDescriptionFontSize = self.itemDescriptionFontSize
            menuItem.itemValueFontSize = self.itemValueFontSize
            menuItem.itemNameFontStyle = self.itemNameFontStyle
            menuItem.itemDescriptionFontStyle = self.itemDescriptionFontStyle
            menuItem.itemValueFontStyle = self.itemValueFontStyle
            menuItem.data = item
            self.addArrangedSubview(menuItem)
        }
    }
    
    private func addType9Menu(with item: MenuItemDetails) {
        if let menuItem = Bundle.main.loadNibNamed("Type9Menu", owner: nil, options: nil)?.first as? Type9Menu {
            menuItem.columnWidth = self.columnWidth
            menuItem.noOfColumns = self.maxColumns
            menuItem.headingFontColor = self.headingColor
            menuItem.descriptionFontColor = self.descriptionColor
            menuItem.valueFontColor = self.valueColor
            menuItem.itemNameFontSize = self.itemNameFontSize
            menuItem.itemDescriptionFontSize = self.itemDescriptionFontSize
            menuItem.itemValueFontSize = self.itemValueFontSize
            menuItem.itemNameFontStyle = self.itemNameFontStyle
            menuItem.itemDescriptionFontStyle = self.itemDescriptionFontStyle
            menuItem.itemValueFontStyle = self.itemValueFontStyle
            menuItem.data = item
            self.addArrangedSubview(menuItem)
        }
    }
    
    private func addType10Menu(with item: MenuItemDetails) {
        if let menuItem = Bundle.main.loadNibNamed("Type10Menu", owner: nil, options: nil)?.first as? Type10Menu {
            menuItem.columnWidth = self.columnWidth
            menuItem.noOfColumns = self.maxColumns
            menuItem.headingFontColor = self.headingColor
            menuItem.descriptionFontColor = self.descriptionColor
            menuItem.valueFontColor = self.valueColor
            menuItem.itemNameFontSize = self.itemNameFontSize
            menuItem.itemValueFontSize = self.itemValueFontSize
            menuItem.itemNameFontStyle = self.itemNameFontStyle
            menuItem.itemValueFontStyle = self.itemValueFontStyle
            menuItem.data = item
            self.addArrangedSubview(menuItem)
        }
    }
    
    private func addType11Menu(with item: MenuItemDetails) {
        if let menuItem = Bundle.main.loadNibNamed("Type11Menu", owner: nil, options: nil)?.first as? Type11Menu {
            menuItem.columnWidth = self.columnWidth
            menuItem.headingFontColor = self.headingColor
            menuItem.descriptionFontColor = self.descriptionColor
            menuItem.valueFontColor = self.valueColor
            menuItem.itemNameFontSize = self.itemNameFontSize
            menuItem.itemDescriptionFontSize = self.itemDescriptionFontSize
            menuItem.itemValueFontSize = self.itemValueFontSize
            menuItem.itemNameFontStyle = self.itemNameFontStyle
            menuItem.itemDescriptionFontStyle = self.itemDescriptionFontStyle
            menuItem.itemValueFontStyle = self.itemValueFontStyle
            menuItem.data = item
            self.addArrangedSubview(menuItem)
        }
    }
    
    private func addType12Menu(with item: MenuItemDetails) {
        if let menuItem = Bundle.main.loadNibNamed("Type12Menu", owner: nil, options: nil)?.first as? Type12Menu {
            menuItem.columnWidth = self.columnWidth
            menuItem.noOfColumns = self.maxColumns
            menuItem.headingFontColor = self.headingColor
            menuItem.descriptionFontColor = self.descriptionColor
            menuItem.valueFontColor = self.valueColor
            menuItem.itemNameFontSize = self.itemNameFontSize
            menuItem.itemDescriptionFontSize = self.itemDescriptionFontSize
            menuItem.itemValueFontSize = self.itemValueFontSize
            menuItem.itemNameFontStyle = self.itemNameFontStyle
            menuItem.itemDescriptionFontStyle = self.itemDescriptionFontStyle
            menuItem.itemValueFontStyle = self.itemValueFontStyle
            menuItem.data = item
            self.addArrangedSubview(menuItem)
        }
    }
    
    private func addType13Menu(with item: MenuItemDetails) {
        if let menuItem = Bundle.main.loadNibNamed("Type13Menu", owner: nil, options: nil)?.first as? Type13Menu {
            menuItem.columnWidth = self.columnWidth
            menuItem.noOfColumns = self.maxColumns
            menuItem.headingFontColor = self.headingColor
            menuItem.descriptionFontColor = self.descriptionColor
            menuItem.valueFontColor = self.valueColor
            menuItem.itemNameFontSize = self.itemNameFontSize
            menuItem.itemDescriptionFontSize = self.itemDescriptionFontSize
            menuItem.itemValueFontSize = self.itemValueFontSize
            menuItem.itemNameFontStyle = self.itemNameFontStyle
            menuItem.itemDescriptionFontStyle = self.itemDescriptionFontStyle
            menuItem.itemValueFontStyle = self.itemValueFontStyle
            menuItem.data = item
            self.addArrangedSubview(menuItem)
        }
    }
}

// MARK: - Public methods
extension GridView {
    func addDataInView() {
        for index in 0...data.count - 1 {
            let item = data[index]
            switch menuStyle {
            case .type1:
                self.addType1Menu(with: item)
            case .type2:
                self.addType2Menu(with: item)
            case .type3:
                self.addType3Menu(with: item)
            case .type4:
                self.addType4Menu(with: item)
            case .type5:
                self.addType5Menu(with: item)
            case .type6:
                self.addType6Menu(with: item)
            case .type7:
                self.addType7Menu(with: item)
            case .type8:
                self.addType8Menu(with: item)
            case .type9:
                self.addType9Menu(with: item)
            case .type10:
                self.addType10Menu(with: item)
            case .type11:
                self.addType11Menu(with: item)
            case .type12:
                self.addType12Menu(with: item)
            case .type13:
                self.addType13Menu(with: item)
            }
        }
    }
}
