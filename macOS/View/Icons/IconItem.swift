//
//  IconItem.swift
//  Swimbols
//
//  Created by Imthathullah M on 12/10/20.
//

import Cocoa
import CanvasKit

protocol IconItemDelegate: class {
    func updateFavorites()
}

final class IconItem: NSCollectionViewItem {
    //  let label = Label()
    lazy var iconView = NSImageView()
    lazy var nameField = NSTextField()
    lazy var favIcon = NSImageView()
    lazy var borderView = NSView()
    
    var icon: SWIcon? = nil
    weak var delegate: IconItemDelegate? = nil
    
    override func loadView() {
        let cellView = IconView()
        cellView.delegate = self
        self.view = cellView
        self.view.wantsLayer = true
        view.fixWidth(Constant.collectionCellWidth)
        view.fixHeight(Constant.collectionCellHeight)
    }
    
    override func viewDidLoad() {
        layoutViews()
        configureViews()
    }
    
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
     
            if isSelected {
                if icon?.isMulticolor ?? false {
                    borderView.layer?.backgroundColor = NSColor.selectedControlColor.cgColor
                } else {
                    borderView.layer?.backgroundColor = NSColor.controlAccentColor.cgColor
                }
            } else {
                setBackground()
            }
        }
    }
    
    func setBackground() {
        if icon?.isMulticolor ?? false {
            borderView.layer?.backgroundColor = NSColor.unemphasizedSelectedContentBackgroundColor.cgColor
        } else {
            borderView.layer?.backgroundColor = .clear
        }
    }
    
    func layoutViews() {
        view.addSubview(borderView)
        borderView.alignTop(with: view, offset: .small)
        borderView.fixHeight(80)
        
        view.addSubview(iconView)
        iconView.align([.centerX, .centerY], with: borderView)
        
        view.addSubview(nameField)
        nameField.align(.centerX, with: borderView)
        nameField.align(.top, with: borderView, on: .bottom, offset: .small)
        nameField.fixHeight(48)
        nameField.fixWidth(88)
        
        view.addSubview(favIcon)
        favIcon.align(.top, with: borderView, offset: .small)
        favIcon.align(.trailing, with: borderView, offset: -.small/2)
    }
    
    func configureViews() {
        
        borderView.wantsLayer = true
        borderView.layer?.borderWidth = 1
        borderView.layer?.cornerRadius = .small
        borderView.layer?.borderColor = NSColor.quaternaryLabelColor.cgColor
        
        nameField.drawsBackground = false
        nameField.alignment = .center
        nameField.isEditable = false
        nameField.isBordered = false
        nameField.maximumNumberOfLines = 2
        nameField.cell?.truncatesLastVisibleLine = true
        nameField.cell?.usesSingleLineMode = false
        
        setBackground()
        
        guard let icon = self.icon else { return }
        
        if icon.isFavorite {
            favIcon.image = NSImage(systemSymbolName: "heart.fill", accessibilityDescription: nil)
            favIcon.contentTintColor = .systemRed
        } else {
            favIcon.image = nil
        }
    }
    
    func set(_ icon: SWIcon) {
        self.icon = icon
        
        // adding a unicode zero width space after each period, so that the system breaks
        // the first line at the last period, instead of at maximum width
        nameField.stringValue = icon.title.replacingOccurrences(of: ".", with: ".\u{200B}")
        
        var image = NSImage(systemSymbolName: icon.title, accessibilityDescription: nil)
        image = image?.withSymbolConfiguration(NSImage.SymbolConfiguration(pointSize: 36, weight: .medium))
        
        image?.isTemplate = !icon.isMulticolor
        iconView.image = image
        iconView.contentTintColor = NSColor.labelColor
    }
}

extension IconItem: IconViewDelegate {
    
    var isFavorite: Bool {
        icon?.isFavorite ?? false
    }
    
    func highlightItem() {
        borderView.layer?.borderColor = NSColor.controlAccentColor.cgColor
    }
    
    func removeHighlight() {
        borderView.layer?.borderColor = NSColor.quaternaryLabelColor.cgColor
    }
    
    func addFavorite() {
        guard ProductStore.shared.isPurchased else {
//            SFPreferences.shared.showUpgradeScreen = true
            return
        }
        
        guard let icon = icon else {
            return
        }
        
        icon.isFavorite.toggle()
        SymbolStore.updateContext()
        delegate?.updateFavorites()
    }
}
