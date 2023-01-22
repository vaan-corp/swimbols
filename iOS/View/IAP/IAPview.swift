//
//  SplitView.swift
//  SymbolCode
//
//  Created by Imthath M on 19/07/20.
//

import SwiftUI
import RevenueCat
import CanvasKit
import StoreKit

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
  
  @State var showLiteView = false
  
  var showCloseButton: Bool = false
  
  var body: some View {
    fullView
  }
  
  var fullView: some View {
    ScrollView {
      viewStack
    }
    .clipped()
    .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
  }
  
  var viewStack: some View {
    VStack(alignment: .center, spacing: 5.0) {
      HStack {
        if showCloseButton {
          Button("Close") {
            self.presentationMode.wrappedValue.dismiss()
          }
          .foregroundColor(.secondary)
          .padding([.leading, .top])
        } else {
          Button("Swimbols Lite") {
            showLiteView = true
          }
          .sheet(isPresented: $showLiteView, content: { LiteView() } )
          .padding(.leading)
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
    ScrollView {
      VStack(alignment: .center, spacing: 5.0) {
        HStack {
          Button {
            presentationMode.wrappedValue.dismiss()
          } label: {
            Text("Close")
          }
          .padding([.leading, .top])
          Spacer()
        }
        IconText(version: .lite)
        FeaturesText(version: .lite)
      }
      .padding(EdgeInsets(top: 10, leading: 10.0, bottom: 44, trailing: 10.0))
    }
    .clipped()
    .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
    .navigationBarHidden(true)
    
  }
}

struct PackageGroup: View {
  
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @ObservedObject var productStore = ProductStore.shared
  
  var body: some View {
    if productStore.isLoading {
      ActivityIndicator.large
        .padding([.top, .bottom], .averageTouchSize * 3)
    } else if productStore.offering == nil {
      Text("Unable to connect to app store at the moment.")
        .padding([.top, .bottom], .averageTouchSize * 2)
    } else {
      purchaseGroup
    }
  }
  
  @ViewBuilder var purchaseGroup: some View {
    if horizontalSizeClass == .compact {
      //            firstTimerText
      subscriptionCards
      //            founderText
      oneTimeCard
    } else if horizontalSizeClass == .regular {
      //            firstTimerText
      HStack {
        subscriptionCards
        oneTimeCard
      }
      //            founderText
    }
    restoreText
  }
  
  @ViewBuilder var subscriptionCards: some View {
    view(forID: ProductStore.MONTHLY_ID)
    view(forID: ProductStore.YEARLY_ID)
  }
  
  @ViewBuilder func view(forID productID: String) -> some View {
    if let monthlyPackage = productStore.offering?[productID] {
      PackageView(package: monthlyPackage)
    }
  }
  
  var firstTimerText: some View {
    Text("Purchase with a subscription of your choice.")
    //        Text("Do you want to try Pro before you pay? Check out these subscriptions with \(Text("two weeks free trial!").bold().foregroundColor(Color(UIColor.label)))")
      .foregroundColor(Color(UIColor.secondaryLabel))
    //                .font(.footnote)
      .multilineTextAlignment(.center)
  }
  
  @ViewBuilder var oneTimeCard: some View {
    view(forID: ProductStore.LIFETIME_ID)
    //        PriceCard(price: "$ 49.99", duration: "lifetime, special launch offer", description: "Hurry, limited period only", color: Color.blue.opacity(0.7))
  }
  
  var founderText: some View {
    Text("Love Swimbols? Support us early with a one time purchase which delivers immense value.")
      .foregroundColor(Color(UIColor.secondaryLabel))
    //            .font(.footnote)
      .multilineTextAlignment(.center)
    //            .padding(.top)
  }
  
  var restoreText: some View {
    Text("If you have already purchased Swimbols, you can restore it \(Text("here").foregroundColor(.accentColor).underline()).")
      .foregroundColor(.secondary)
      .multilineTextAlignment(.center)
      .onTapGesture {
        productStore.isLoading = true
        Purchases.shared.restorePurchases { (purchaserInfo, error) in
          productStore.isLoading = false
          //... check purchaserInfo to see if entitlement is now active
          if let paidEntitlement = purchaserInfo?.entitlements[ProductStore.ENTITLEMENT_ID] {
            "\(paidEntitlement)".log()
            if paidEntitlement.isActive {
              productStore.state = .restored
            }
            //                        productStore.isRestored = paidEntitlement.isActive
            //                        productStore.isPurchased = paidEntitlement.isActive
            // Unlock that great "pro" content
          } else if let restoreError = error as NSError? {
            restoreError.localizedDescription.log()
            productStore.handle(restoreError)
          }
        }
      }
  }
}

struct PackageView: View {
  
  //    @State var isLoading = false
  @ObservedObject var productStore = ProductStore.shared
  var package: Package
  
  var body: some View {
    PriceCard(price: price, duration: title, description: description, color: color)
      .contentShape(Rectangle())
      .onTapGesture {
        productStore.isLoading = true
        Purchases.shared.purchase(package: package, completion: handlePurchase)
      }
  }
  
  @MainActor @Sendable
  func handlePurchase(transaction: StoreTransaction?, purchaserInfo: CustomerInfo?, error: NSError?, userCancelled: Bool) {
    productStore.isLoading = false
    
#if DEBUG
    if let skTransaction = transaction {
      switch skTransaction.transactionState {
      case .purchased:
        productStore.state = .transacted
        return
      case .restored:
        productStore.state = .restored
      default:
        productStore.alertTitle = ProductStore.purchaseFailure
        productStore.alertMessage = ProductStore.generalError
        productStore.showAlert = true
      }
    }
#endif
    
    if userCancelled {
      productStore.alertTitle = "What stopped you?"
      productStore.alertMessage = ProductStore.userCancelled
      productStore.showAlert = true
    } else if let paidEntitlement = purchaserInfo?.entitlements[ProductStore.ENTITLEMENT_ID] {
      "\(paidEntitlement)".log()
      if paidEntitlement.isActive {
        productStore.state = .transacted
      }
      //            productStore.isPurchased = paidEntitlement.isActive
      // Unlock that great "pro" content
    } else if let purchaseError = error as NSError? {
      purchaseError.localizedDescription.log()
      productStore.handle(purchaseError)
    }
    
  }
  
  var price: String {
    package.localizedPriceString
  }
  
  var description: String {
    package.storeProduct.localizedDescription
  }
  
  var title: String {
    package.storeProduct.localizedTitle
  }
  
  var color: Color {
    switch package.identifier {
    case ProductStore.MONTHLY_ID: return Color.pink.opacity(0.6)
    case ProductStore.YEARLY_ID: return Color.green.opacity(0.7)
    case ProductStore.LIFETIME_ID: return Color.blue.opacity(0.7)
    default:
      "Unknown identifier \(package.storeProduct.productIdentifier)".log()
      return Color.yellow
    }
  }
}

//struct PurchaseItem: View {
//
//    var identifier: String
//    var localizedPrice: String
//
//
//    var description: String {
//        switch identifier {
//        case
//        }
//    }
//
//    var duration: String {
//
//    }
//
//    var color: Color {
//
//    }
//
//    var body: some View {
//
//    }
//}


struct IAPphone_Previews: PreviewProvider {
  static var previews: some View {
    //        IAPphone()
    LiteView()
    //        FeaturesText()
    //            .makeForPreviewProvider(includeLightMode: true, includeDarkMode: true, includeRightToLeftMode: false, includeLargeTextMode: true)
  }
}
