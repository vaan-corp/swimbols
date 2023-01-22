//
//  ModifiersVC.swift
//  Swimbols
//
//  Created by Imthathullah M on 12/10/20.
//

import Cocoa
import CanvasKit

protocol AppliedModifiersDelegate: class {
    func reloadAllModifiers()
}

class AppliedModifiersVC: SDTableViewController {
    
    var model: ViewModel { preferences.model }
    
    var preferences: SFPreferences
    
    weak var delegate: AppliedModifiersDelegate?
    
    init(_ preferences:SFPreferences) {
        self.preferences = preferences
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var modifiers: [Modifier] { model.modifiers }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.addColumn(withID: "applied", header: "Applied Modifiers")
//        addColumnWithCustomHeader()
        tableView.backgroundColor = NSColor.windowBackgroundColor
        tableView.style = .plain
//        tableView.gridStyleMask = .solidHorizontalGridLineMask
//        tableView.gridStyleMask = .dashedHorizontalGridLineMask
        tableView.registerForDraggedTypes([.string])
    }
    
//    func addColumnWithCustomHeader() {
//        let headerView = NSTableHeaderView()
//        let titleView = SDTextView(Constant.appliedModifiers)
//        titleView.textColor = NSColor.secondaryLabelColor
//
//        headerView.fixHeight(33)
//        headerView.minWidth(120)
//        headerView.addSubview(titleView)
//        titleView.alignEdges(with: headerView, offset: .zero)
//
//        let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "col"))
//        col.minWidth = Constant.sidebarWidth
//        self.tableView.headerView = headerView
//
//
//        tableView.addTableColumn(col)
//    }
    
    // MARK: NSTableViewDataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        modifiers.count
    }
    
    // MARK: NSTableViewDelegate
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let view = AppliedModifierView(modifiers[row], row: row)
        view.delegate = self
        return view
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow: Int) -> CGFloat {
        switch modifiers[heightOfRow].type {
        case .rotation, .fontSize: return 72
        default: return 36
        }
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
}

extension AppliedModifiersVC: AppliedModifierDelegate {
    
    func takeUp(_ modifier: Modifier, from index: Int) {
        guard index > 0 else { return }
        preferences.model.modifiers.move(fromOffsets: IndexSet(integer: index), toOffset: index-1)
        tableView.reloadData()
    }
    
    func takeDown(_ modifier: Modifier, from index: Int) {
        guard index < modifiers.count - 1 else { return }
        preferences.model.modifiers.remove(at: index)
        preferences.model.modifiers.insert(modifier, at: index+1)
//        preferences.model.modifiers.move(fromOffsets: IndexSet(integer: index), toOffset: index+1)
        tableView.reloadData()
    }
    
    func delete(_ modifier: Modifier, from index: Int) {
        preferences.model.modifiers.remove(at: index)
        tableView.reloadData()
    }
}

//MARK:- row action delegate
extension AppliedModifiersVC {
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        guard edge == .trailing else {
            "No row action specified on leading edge for row \(row)".log()
            return []
        }
        
        let deleteAction = NSTableViewRowAction(style: .destructive, title: "Delete", handler: handleAction(_:at:))
        deleteAction.image = NSImage(systemSymbolName: "trash.fill", accessibilityDescription: "delete modifier")
        return [deleteAction]
    }
    
    func handleAction(_ action: NSTableViewRowAction, at index: Int) {
        tableView.removeRows(at: IndexSet(integer: index), withAnimation: .slideLeft)
        preferences.model.modifiers.remove(at: index)
        delegate?.reloadAllModifiers()
        // the delay is to let the delete completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.tableView.reloadData()
        })
    }
}

//MARK:- drag and drop delegates
extension AppliedModifiersVC {
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        guard let data = try? JSONEncoder().encode(modifiers[row]),
              let string = String(data: data, encoding: .utf8) else {
            "Unable to encode modifier data".log()
            return nil
        }
        return string as NSString
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {

       guard dropOperation == .above,
             let dragSource = info.draggingSource as? NSTableView,
             tableView == dragSource else {
        "Unable to validate drop for drag operation \(dropOperation) at row \(row) from source \(info.draggingSource ?? "NOT FOUND")".log()
        return []
       }

       dragSource.draggingDestinationFeedbackStyle = .gap
       return .move
     }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {

        /* Read the pasteboard items and ensure there is at least one item,
         find the string of the first pasteboard item and search the datasource
         for the index of the matching string */
        guard let items = info.draggingPasteboard.pasteboardItems,
              let pasteBoardItem = items.first,
              let pasteBoardItemName = pasteBoardItem.string(forType: .string),
              let data = pasteBoardItemName.data(using: .utf8),
              let modifier = try? JSONDecoder().decode(Modifier.self, from: data),
              let index = modifiers.firstIndex(where: { $0.id == modifier.id }) else {
            "Unable to accept drop info".log()
            return false
            
        }

        /* Animate the move to the rows in the table view. The ternary operator
         is needed because dragging a row downwards means the row number is 1 less */
        tableView.beginUpdates()
        tableView.moveRow(at: index, to: (index < row ? row - 1 : row))
        tableView.endUpdates()
        
        let indexset = IndexSet(integer: index)
        preferences.model.modifiers.move(fromOffsets: indexset, toOffset: row)

        
        tableView.reloadData()
        return true
      }
}
