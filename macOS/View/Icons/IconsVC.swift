//
//  IconsVC.swift
//  Swimbols
//
//  Created by Imthathullah M on 11/10/20.
//

import CanvasKit
import Cocoa
// import HotKey

protocol IconsDelegate: class {
  func selectedIcon(_ icon: SWIcon)
}

class IconsVC: NSViewController, IconItemDelegate {
  lazy var collectionView = NSCollectionView(frame: view.frame)
  lazy var scrollView = NSScrollView(frame: view.frame)
  lazy var category: SWCategory? = nil
  
  weak var delegate: IconsDelegate? = nil
  var showingFavorites: Bool { favoritesButton.state == .on }
  lazy var isSearching: Bool = false
  lazy var icons = [SWIcon]()
  
  //    lazy var searchKey = HotKey(key: .f, modifiers: [.command])
  //    lazy var escKey = HotKey(key: .escape, modifiers: [])
  
  var startSearchButton: NSButton = {
    let button = NSButton(title: "startSearch", target: self, action: #selector(startSearch))
    button.keyEquivalent = "f"
    button.keyEquivalentModifierMask = .command
    return button
  }()
  
  var endSearchButton: NSButton = {
    let button = NSButton(title: "endSearch", target: self, action: #selector(endSearch))
    button.keyEquivalent = "\u{1b}"
    //        button.keyEquivalentModifierMask = .command
    return button
  }()
  
  lazy var favoritesButton: NSButton = {
    let image = NSImage(systemSymbolName: "heart.fill", accessibilityDescription: nil)!
    image.isTemplate = true
    
    let button = NSButton(image: image,
                          target: self, action: #selector(updateFavorites))
    button.bezelStyle = .texturedRounded
    button.setButtonType(.pushOnPushOff)
    
    return button
  }()
  
  lazy var searchItem: NSSearchToolbarItem = {
    let item = NSSearchToolbarItem(itemIdentifier: .search)
    item.searchField.delegate = self
    return item
  }()
  
  init() {
    super.init(nibName: nil, bundle: nil)
    category = SymbolStore.shared.category(atPosition: 1)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func loadView() {
    self.view = NSView()
    view.minWidth(360)
    view.minHeight(600)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupKeys()
    configureCollectionView()
    view.addSubview(scrollView)
    scrollView.alignEdges(with: view)
    
    //        view.addSubview(startSearchButton)
    //        view.addSubview(endSearchButton)
    
    //        startSearchButton.isHidden = true
    //        endSearchButton.isHidden = true
  }
  
  func setupKeys() {
    favoritesButton.keyEquivalent = "h"
    favoritesButton.keyEquivalentModifierMask = .command
    
    //        searchKey.keyDownHandler = startSearch
    //        escKey.keyDownHandler = endSearch
  }
  
  @objc func startSearch() {
    searchItem.searchField.becomeFirstResponder()
  }
  
  @objc func endSearch() {
    isSearching = false
    searchItem.searchField.stringValue = ""
    searchItem.endSearchInteraction()
    collectionView.reloadData()
  }
  
  @objc func updateFavorites() {
    guard ProductStore.shared.isPurchased else {
      //            SFPreferences.shared.showUpgradeScreen = true
      favoritesButton.state = .off
      return
    }
    endSearch()
    if showingFavorites {
      icons = SymbolStore.shared.favoriteIcons
      view.window?.subtitle = "Favorites"
    } else {
      view.window?.subtitle = category?.displayValue ?? "All"
    }
    
    collectionView.reloadData()
  }
  
  func configureCollectionView() {
    let layout = NSCollectionViewFlowLayout()
    layout.minimumLineSpacing = 4
    layout.minimumInteritemSpacing = .zero
    
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.collectionViewLayout = layout
    collectionView.allowsMultipleSelection = false
    collectionView.backgroundColors = [.clear]
    collectionView.isSelectable = true
    collectionView.register(
      IconItem.self,
      forItemWithIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CategoryCell")
    )
    
    scrollView.documentView = collectionView
  }
  
  func update(_ category: SWCategory) {
    self.category = category
    
    if isSearching {
      self.view.window?.subtitle = "Search results in \(category.displayValue)"
      icons = category.sortedSymbols.filter({ $0.identifier!.localizedCaseInsensitiveContains(searchItem.searchField.stringValue) })
    } else if showingFavorites {
      self.view.window?.subtitle = "Favorites in \(category.displayValue)"
      icons = category.sortedSymbols.filter({ $0.isFavorite })
    } else {
      self.view.window?.subtitle = category.displayValue
    }
    
    collectionView.reloadData()
  }
}

extension IconsVC: NSCollectionViewDataSource {
  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    if showingFavorites || isSearching {
      return icons.count
    }
    
    return category?.symbols?.count ?? 0
  }
  
  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    guard let icon = getIcon(at: indexPath) else {
      Message.iconMissing(at: indexPath.item).log()
      return NSCollectionViewItem()
    }
    guard let item = collectionView.makeItem(
      withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "CategoryCell"),
      for: indexPath
    ) as? IconItem else {
      Message.collectionCellFailure.log()
      return NSCollectionViewItem()
    }
    
    item.set(icon)
    item.configureViews()
    item.layoutViews()
    item.delegate = self
    
    return item
  }
  
  func getIcon(at indexPath: IndexPath) -> SWIcon? {
    if showingFavorites || isSearching {
      return icons[safe: indexPath.item]
    }
    
    return category?.sortedSymbols[safe: indexPath.item]
  }
}

extension IconsVC: NSCollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    guard let indexPath = indexPaths.first,
          let icon = icon(at: indexPath.item) else { return }
    
    delegate?.selectedIcon(icon)
  }
  
  func icon(at index: Int) -> SWIcon? {
    if isSearching || showingFavorites {
      if let icon = icons[safe: index] {
        return icon
      }
    } else if let icon = category?.sortedSymbols[safe: index] {
      return icon
    }
    
    return nil
  }
  
  func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
    //        guard let indexPath = indexPaths.first,
    //              let icon = category?.sortedSymbols[safe: indexPath.item],
    //              let cell = collectionView.item(at: indexPath) as? IconItem else {
    //            return
    //        }
    
  }
  
  func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> NSSize {
    return NSSize(
      width: Constant.collectionCellWidth,
      height: Constant.collectionCellHeight
    )
  }
}

extension IconsVC: NSSearchFieldDelegate {
  func searchFieldDidStartSearching(_ sender: NSSearchField) {
    isSearching = true
    favoritesButton.state = .off
    view.window?.subtitle = "Search Results"
  }
  
  func searchFieldDidEndSearching(_ sender: NSSearchField) {
    isSearching = false
    view.window?.subtitle = category?.displayValue ?? ""
  }
  
  func controlTextDidChange(_ obj: Notification) {
    guard let searchField = obj.object as? NSSearchField else {
      return
    }
    
    icons = SymbolStore.shared.searchSymbols(matchingKeyword: searchField.stringValue)
    collectionView.reloadData()
  }
}
