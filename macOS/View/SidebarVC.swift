//
//  SidebarVC.swift
//  Swimbols
//
//  Created by Imthathullah M on 10/10/20.
//

import Cocoa
import CanvasKit

protocol SidebarDelegate: class {
    func selected(_ category: SWCategory)
}

class SidebarVC: NSViewController,
                 NSTableViewDelegate,
                 NSTableViewDataSource,
                 NSFetchedResultsControllerDelegate {
    
    // MARK: Constants
    var minWidth: CGFloat { Constant.sidebarWidth }
    
    var initialized = false
    let scrollView = NSScrollView()
    let tableView = NSTableView()
    
    weak var delegate: SidebarDelegate?
    
    private lazy var fetchedResultsController: NSFetchedResultsController<SWCategory> = {
        let fetchRequest: NSFetchRequest<SWCategory> = SWCategory.fetchRequest()
//        fetchRequest.predicate = predicate ...
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \SWCategory.position, ascending: true)]
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: SymbolStore.shared.context, sectionNameKeyPath: nil, cacheName: nil)
        frc.delegate = self
        return frc
    }()

    override func loadView() {
        "load view".log()
        self.view = NSView()
        setupView()
//        self.view = NSView(frame: NSRect(x: 0, y: 0, width: 100, height: 900))
    }

    override func viewDidLoad() {
        "view did load".log()
        super.viewDidLoad()
        do {
            try fetchedResultsController.performFetch()
//            if let firstCategory = fetchedResultsController.fetchedObjects?.first {
//                let indexSet = IndexSet(integer: 0)
//                tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
//                delegate?.selected(firstCategory)
//            }
        } catch let error {
            debugPrint("\(error)")
        }
        
    }
    
    override func viewDidLayout() {
        if !initialized {
            initialized = true
            setupView()
            setupTableView()
        }
    }
    
    func setupView() {
//        self.view.translatesAutoresizingMaskIntoConstraints = false
        view.minWidth(200)
        view.minHeight(600)
        view.maxHeight(1900)
    }
    
    func setupTableView() {
        self.view.addSubview(scrollView)
        scrollView.alignEdges(with: view)
        configure(tableView, in: scrollView)
        tableView.addColumn(withID: "sidebar", header: nil, width: Constant.sidebarWidth)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.style = .sourceList
    }
    
    // MARK: NSTableView Delegate and DataSource
    func numberOfRows(in tableView: NSTableView) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        return getCell(for: row)
    }
    
    private func getCell(for row: Int) -> NSView {
        guard let category = fetchedResultsController.fetchedObjects?[row] else {
            let cell = NSTableCellView()
//            cell.textField?.stringValue = "not found"
            return cell
        }
        
        let rowView = NSTableCellView()
        rowView.minWidth(minWidth)
        let nameField = NSTextField()
        nameField.stringValue = category.displayValue
        nameField.drawsBackground = false
        nameField.isBordered = false
        nameField.isEditable = false

        let imageView = NSImageView()
        imageView.image = NSImage(systemSymbolName: category.displayIcon, accessibilityDescription: nil)
            //?.withSymbolConfiguration(NSImage.SymbolConfiguration(scale: .large))
//        imageView.image =
        imageView.contentTintColor = NSColor.controlAccentColor

        rowView.addSubview(imageView)
        imageView.align([.centerY, .leading], with: rowView)
        imageView.fixWidth(33)
        
        rowView.addSubview(nameField)
        nameField.align([.centerY, .trailing], with: rowView)
        nameField.align(.leading, with: imageView, on: .trailing)
        return rowView
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow: Int) -> CGFloat {
        return 33
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        guard let category = fetchedResultsController.fetchedObjects?[row] else {
            Message.categoryMissing(at: row).log()
            return false
        }
        
        guard let delegate = self.delegate else {
            Message.delegateMissing(for: "SidebarVC").log()
            assertionFailure()
            return false
        }
        
        delegate.selected(category)
        
        return true
    }
    
    // MARK: NSFetchedResultsControllerDelegate:
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?){
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath.item], withAnimation: .effectFade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.removeRows(at: [indexPath.item], withAnimation: .effectFade)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadData(forRowIndexes: [indexPath.item], columnIndexes: [indexPath.item])
//                let row = indexPath.item
//                for column in 0..<tableView.numberOfColumns {
//                    if var cell = tableView.view(atColumn: column, row: row, makeIfNecessary: true) as? NSTableCellView {
//                        cell = getCell(for: row)
//                    }
//                }
            }
            
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.removeRows(at: [indexPath.item], withAnimation: .effectFade)
                tableView.insertRows(at: [newIndexPath.item], withAnimation: .effectFade)
            }
        @unknown default:
            assertionFailure("new case")
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

}
