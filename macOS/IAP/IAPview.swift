//
//  SplitView.swift
//  SymbolCode
//
//  Created by Imthath M on 19/07/20.
//

import CanvasKit
import RevenueCat
import SwiftUI

public enum SwimbolVersion {
  case lite, pro
  
  var isLite: Bool { self == .lite }
  
  mutating func toggle() {
    switch self {
    case .lite: self = .pro
    case .pro: self = .lite
    }
  }
  
  var name: String {
    switch self {
    case .lite: return "Lite"
    case .pro: return "Pro"
    }
  }
  
  var fontWeight: Font.Weight {
    switch self {
    case .lite: return .light
    case .pro: return .semibold
    }
  }
  
  var alternateText: String {
    switch self {
    case .lite: return "Swimbols Pro"
    case .pro: return "Swimbols Lite"
    }
  }
}

struct IAPphone: View {
  @Environment(\.presentationMode) var presentationMode
  
  @ObservedObject var productStore = ProductStore.shared
  
  @State var version = SwimbolVersion.pro
  
  var showCloseButton: Bool = false
  
  var body: some View {
    fullView
      .frame(minWidth: 400, idealWidth: 600, maxWidth: .infinity,
             minHeight: 600, idealHeight: 900, maxHeight: .infinity)
  }
  
  var fullView: some View {
    ScrollView {
      viewStack
    }
    .clipped()
  }
  
  var viewStack: some View {
    VStack(alignment: .center, spacing: 5.0) {
      HStack {
        if showCloseButton {
          Button(action: {
            Router.shared.splitVC.host.dismiss(Router.shared.splitVC.host)
          }, label: {
            Image(systemName: "multiply")
          })
          .foregroundColor(.secondary)
          .padding([.leading, .top])
        } else {
          NavigationLink(
            destination: LiteView(),
            label: {
              Text("Swimbols Lite")
            })
        }
        Spacer()
      }
      
      IconText(version: .pro)
      
      PackageGroup()
        .padding(.bottom)
      FeaturesText(version: .pro)
    }
    .padding(EdgeInsets(top: 10, leading: 10.0, bottom: 44, trailing: 10.0))
    
    .simpleAlert(isPresented: $productStore.showAlert, title: productStore.alertTitle, message: productStore.alertMessage)
  }
}

struct LiteView: View {
  @Environment(\.presentationMode) var presentationMode
  
  var body: some View {
    fullView
      .inNormalWindow
    //        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    //        .navigationBarHidden(true)
    
  }
  
  var fullView: some View {
    ScrollView {
      VStack(alignment: .center, spacing: 5.0) {
        HStack {
          Button {
            presentationMode.wrappedValue.dismiss()
          } label: {
            TNLabel("Back", systemImage: "chevron.left")
          }
          .padding(.leading)
          Spacer()
        }
        IconText(version: .lite)
        FeaturesText(version: .lite)
      }
      .padding(EdgeInsets(top: 10, leading: 10.0, bottom: 44, trailing: 10.0))
    }
    .clipped()
  }
}

struct PackageGroup: View {
  @ObservedObject var productStore = ProductStore.shared
  @State var showPurchaseCompletedView = false
  var body: some View {
    if productStore.isLoading {
      ActivityIndicator(isAnimating: $productStore.isLoading)
        .padding([.top, .bottom], .averageTouchSize * 3)
    } else if productStore.offering == nil {
      Text("Unable to connect to app store at the moment.")
        .padding([.top, .bottom], .averageTouchSize * 2)
    } else {
      radioGroup
    }
  }
  
  @State var selection: String = ProductStore.LIFETIME_ID
  
  @ViewBuilder var radioGroup: some View {
    Text("Upgrade to Swimbols Pro to unlock all features and support the continuous development of the app.")
      .multilineTextAlignment(.center)
      .padding(.top)
    Picker("", selection: $selection, content: {
      card(forID: ProductStore.MONTHLY_ID).tag(ProductStore.MONTHLY_ID)
      card(forID: ProductStore.YEARLY_ID).tag(ProductStore.YEARLY_ID)
      card(forID: ProductStore.LIFETIME_ID).tag(ProductStore.LIFETIME_ID)
    })
    .pickerStyle(RadioGroupPickerStyle())
    
    Button("Upgrade") {
      productStore.isLoading = true
      if let package = productStore.offering?[selection] {
        Purchases.shared.purchase(package: package, completion: handlePurchase)
      }
    }
    .font(.title3)
    .buttonStyle(CardButtonStyle())
    restoreText
  }
  
  @ViewBuilder func card(forID productID: String) -> some View {
    if let package = productStore.offering?[productID] {
      Text("\(Text(package.localizedPriceString).font(.title)), \(package.storeProduct.localizedTitle) \n\(Text(package.storeProduct.localizedDescription).foregroundColor(.secondary))")
        .padding(.small)
    }
  }
  
  var firstTimerText: some View {
    Text("Purchase with a subscription of your choice. The annual one provides the best value for money.")
      .multilineTextAlignment(.center)
  }
  
  var restoreText: some View {
    Text("If you have already purchased Swimbols, you can restore it \(Text("here").foregroundColor(.accentColor).underline()).")
      .foregroundColor(.secondary)
      .multilineTextAlignment(.center)
      .onTapGesture {
        productStore.isLoading = true
        Purchases.shared.restorePurchases { (purchaserInfo, error) in
          productStore.isLoading = false
          // ... check purchaserInfo to see if entitlement is now active
          if let paidEntitlement = purchaserInfo?.entitlements[ProductStore.ENTITLEMENT_ID] {
            "\(paidEntitlement)".log()
            if paidEntitlement.isActive {
              setPurchased()
            } else {
              productStore.alertTitle = "Restore failed"
              productStore.alertMessage = "Kindly ensure you have already bought the product and try restoring again later."
              productStore.showAlert = true
            }
            // Unlock that great "pro" content
          } else if let restoreError = error as NSError? {
            restoreError.localizedDescription.log()
            productStore.handle(restoreError)
          }
        }
      }
  }
  
  @MainActor @Sendable
  func handlePurchase(transaction: StoreTransaction?, purchaserInfo: CustomerInfo?, error: Error?, userCancelled: Bool) {
    productStore.isLoading = false
    
#if DEBUG
    if let skTransaction = transaction {
      switch skTransaction.transactionState {
      case .restored, .purchased:
        setPurchased()
      default:
        productStore.alertTitle = ProductStore.purchaseFailure
        productStore.alertMessage = ProductStore.generalError
        productStore.showAlert = true
      }
      return
    }
#endif
    
    if userCancelled {
      productStore.alertTitle = "What stopped you?"
      productStore.alertMessage = ProductStore.userCancelled
      productStore.showAlert = true
    } else if let paidEntitlement = purchaserInfo?.entitlements[ProductStore.ENTITLEMENT_ID] {
      "\(paidEntitlement)".log()
      if paidEntitlement.isActive {
        setPurchased()
      }
      //            productStore.isPurchased = paidEntitlement.isActive
      // Unlock that great "pro" content
    } else if let purchaseError = error as NSError? {
      purchaseError.localizedDescription.log()
      productStore.handle(purchaseError)
    }
  }
  
  func setPurchased() {
    productStore.state = .purchased
    Router.shared.splitVC.host.dismiss(Router.shared.splitVC.host)
    //        SFPreferences.shared.showUpgradeScreen = true
    
    NSToolbar.removeUpgradeButton()
  }
}

struct IAPphone_Previews: PreviewProvider {
  static var previews: some View {
    //        IAPphone()
    LiteView()
    //        FeaturesText()
    //            .makeForPreviewProvider(includeLightMode: true, includeDarkMode: true, includeRightToLeftMode: false, includeLargeTextMode: true)
  }
}
