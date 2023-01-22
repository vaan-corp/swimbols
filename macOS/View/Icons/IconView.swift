//
//  IconView.swift
//  Swimbols
//
//  Created by Imthathullah M on 12/10/20.
//

import Cocoa
import CanvasKit

protocol IconViewDelegate: class {
    func highlightItem()
    func removeHighlight()
    func addFavorite()
    var isFavorite: Bool { get }
}

class IconView: FlippedView {
    
    weak var delegate: IconViewDelegate?
    
    var isFavorite: Bool { delegate?.isFavorite ?? false }
    
    var favTitle: String { isFavorite ? "Remove favorite" : "Add favorite" }
    
    var favImageName: String { isFavorite ? "heart.slash.fill" : "heart.fill"}
    
    override func menu(for event: NSEvent) -> NSMenu? {
        guard event.type == .rightMouseDown else {
            return nil
        }
        
        delegate?.highlightItem()
        
        let menu = NSMenu(title: "options")
        let favItem = NSMenuItem(title: favTitle, action: #selector(addFavorite), keyEquivalent: "")
        favItem.image = NSImage(systemSymbolName: favImageName, accessibilityDescription: nil)
        
        menu.addItem(favItem)
        menu.delegate = self
        return menu
    }
    
    @objc func addFavorite() {
        delegate?.removeHighlight()
        delegate?.addFavorite()
    }
}

extension IconView: NSMenuDelegate {
    override func didCloseMenu(_ menu: NSMenu, with event: NSEvent?) {
        delegate?.removeHighlight()
    }
}

