//
//  ModifiersSplitVC.swift
//  Swimbols
//
//  Created by Imthathullah M on 13/10/20.
//

import Cocoa
import CanvasKit

class ModifiersSplitVC: NSSplitViewController {
  
  var model: ViewModel { preferences.model }
  
  var preferences: SFPreferences
  
  lazy var appliedVC = AppliedModifiersVC(preferences)
  lazy var availableVC = AvailableModifiersVC()
  
  lazy var appliedItem = NSSplitViewItem(viewController: appliedVC)
  lazy var availableItem = NSSplitViewItem(viewController: availableVC)
  
  init(_ preferences:SFPreferences) {
    self.preferences = preferences
    super.init(nibName: nil, bundle: nil)
    self.splitView.isVertical = false
    self.splitViewItems = [availableItem, appliedItem]
    availableVC.delegate = self
    appliedVC.delegate = self
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension ModifiersSplitVC: AvailableModifiersDelegate {
  
  func added(_ modifier: Modifier) {
    guard !preferences.model.properties.isEmpty else { return }
    
    preferences.model.add(modifier)
    appliedVC.tableView.reloadData()
  }
}

extension ModifiersSplitVC: AppliedModifiersDelegate {
  func reloadAllModifiers() {
    availableVC.tableView.reloadData()
  }
}
