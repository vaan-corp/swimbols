//
//  SplitVC.swift
//  Swimbols
//
//  Created by Imthathullah M on 10/10/20.
//

import SwiftUI
import Cocoa
import CanvasKit
import StoreKit

class Router {
  
  private init() { }
  
  static let shared = Router()
  
  var splitVC: SplitVC = SplitVC()
  
  lazy var iapHost = NSHostingController(rootView: IAPphone())
}

struct ContentWrapper: View {
  @ObservedObject var pref = SFPreferences.shared
  @ObservedObject var productStore = ProductStore.shared
  
  //    @State var sh
  var body: some View {
    SymbolAndOutput(model: $pref.model)
      .disabled(pref.icon == nil)
    //            .alert(isPresented: $pref.showUpgradeScreen, content: getAlert)
  }
  
  func getAlert() -> Alert {
    if productStore.state == .purchased {
      return thankYouAlert()
    }
    
    return upgradeAlert()
  }
  
  var cancelButton: Alert.Button {
    Alert.Button.cancel()
    //        Alert.Button.cancel(Text("Can"))
  }
  
  var upgradeAlertButton: Alert.Button {
    Alert.Button.default(Text("Buy Pro"), action: {
      //            self.showIAPview()
      //            self.showIAPview = true
      Router.shared.splitVC.showIAPview()
    })
  }
  
  func upgradeAlert() -> Alert {
    Alert(title: Text("Upgrade Swimbols?"), message: Text(alertMessage), primaryButton: upgradeAlertButton, secondaryButton: cancelButton)
  }
  
  var alertMessage: String {
    "You are currently using a free version of Swimbols. To use favorites, copy code and support the continuous development of the app, please upgrade to Swimbols Pro."
  }
  
  func thankYouAlert() -> Alert {
    Alert(title: Text("Thank you for \(productStore.state == .restored ? "continuing with us" : "purchasing")!"), message: Text(messageString), dismissButton: .cancel(Text("Continue")))
  }
  
  var messageString: String {
    "We are continuously striving to improve your workflow and productivity when working with SF Symbols.\n\nIf you face any issue or would like a new feature, kindly contact us at imthath.m@icloud.com.\n\nWe value your feedback and we are committed to respond within 3 days. "
  }
}

class SplitVC: NSSplitViewController {
  
  @ObservedObject var pref = SFPreferences.shared
  
  lazy var sidebarVC = SidebarVC()
  lazy var iconsVC = IconsVC()
  lazy var contentVC = NSHostingController(rootView: ContentWrapper())
  lazy var modifiersVC = ModifiersSplitVC(pref) //ModifiersVC(pref)
  
  lazy var sidebarItem = NSSplitViewItem(sidebarWithViewController: sidebarVC)
  lazy var iconsItem = NSSplitViewItem(viewController: iconsVC)
  lazy var contentItem = NSSplitViewItem(viewController: contentVC)
  lazy var modifiersItem = NSSplitViewItem(contentListWithViewController: modifiersVC)
  
  //    lazy var copyKey = HotKey(key: .c, modifiers: .command)
  
  init() {
    super.init(nibName: nil, bundle: nil)
    sidebarVC.delegate = self
    iconsVC.delegate = self
    self.splitViewItems = [sidebarItem, iconsItem, contentItem, modifiersItem]
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    //        setupKeys()
  }
  
  override func viewWillAppear() {
    super.viewWillAppear()
    ProductState.updateCount()
  }
  
  lazy var upgradeButton: NSButton = {
    let image = NSImage(systemSymbolName: "cart.fill.badge.plus", accessibilityDescription: nil)!
    image.isTemplate = true
    
    let button = NSButton(image: image,
                          target: self, action: #selector(showIAPview))
    button.bezelStyle = .texturedRounded
    
    return button
  }()
  
  lazy var iapView = IAPphone(showCloseButton: true)
  lazy var host = NSHostingController(rootView: iapView)
  
  @objc func showIAPview() {
    guard ProductStore.shared.state != .purchased else {
      //            pref.showUpgradeScreen = true
      return
    }
    self.presentAsSheet(host)
  }
  //
  //    func setupKeys() {
  //        copyKey.keyDownHandler = pref.copyCode
  //    }
}

extension SplitVC: SidebarDelegate {
  
  func selected(_ category: SWCategory) {
    SFPreferences.shared.cdCategory = category
    iconsVC.update(category)
  }    
}

extension SplitVC: IconsDelegate {
  
  func selectedIcon(_ icon: SWIcon) {
    //        if pref.icon == nil {
    //            addSplitViewItem(modifiersItem)
    //        }
    pref.model.addProperty(for: icon)
  }
}
