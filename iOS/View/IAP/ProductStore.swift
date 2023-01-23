//
//  ProductStore.swift
//  SFCodePad
//
//  Created by Imthath M on 22/10/20.
//  Copyright © 2020 Imthath. All rights reserved.
//

import CanvasKit
import Combine
import Foundation
import RevenueCat

enum ProductState: Int {
  case installed = 0
  case transacted = 1
  case restored = 2
  case purchased = 3
  case expired = 4
  case limited = 5
}

extension ProductState {
  @CVDefault("productState", defaultValue: 0)
  static var storedRawValue: Int
  
  @CVDefault("activeSessions", defaultValue: 0)
  static var activeSessions: Int64
  
  static var storedValue: ProductState { ProductState(rawValue: storedRawValue) ?? .installed }
}

class ProductStore: ObservableObject {
  private init() {
    Purchases.logLevel = .debug // doubtful
    Purchases.configure(withAPIKey: "llpbLrfUNbLfquPckapPWFDZZlHFxSSK")
  }
  
  public static let shared = ProductStore()
  
  @Published var offering: Offering?
  @Published var isLoading: Bool = false
  
  var isPurchased: Bool { state == .purchased }
  
  var isTrial: Bool { state == .limited }
  
  @Published var state = ProductState.storedValue {
    didSet {
      ProductState.storedRawValue = state.rawValue
      SFPreferences.shared.isTrial = isTrial
    }
  }
  
  @Published var showAlert = false
  var alertMessage = ""
  var alertTitle = ""
  
  func setup() {
    guard Purchases.canMakePayments() else {
      alertMessage = ProductStore.unauthorizedUser
      showAlert = true
      return
    }
    updatePurchaserInfo()
    if !isPurchased {
      updateOfferings()
    }
  }
  
  private func updatePurchaserInfo() {
    Purchases.shared.getCustomerInfo { info, error in
      if let paidEntitlement = info?.entitlements[ProductStore.ENTITLEMENT_ID] {
        "\(paidEntitlement)".log()
        if paidEntitlement.isActive {
          if !self.isPurchased {
            self.state = .purchased
          } else {
            "Continuing as paid user".log()
          }
        } else {
          self.state = .expired
          self.alertTitle = ProductStore.purchaseExpiredTitle
          self.alertMessage = ProductStore.purchaseExpiredMessage
          self.showAlert = true
        }
      } else if let updateError = error as NSError? {
        updateError.localizedDescription.log()
        self.handle(updateError)
      } else {
        if self.state != .limited, self.state != .installed {
          self.state = .limited
        }
      }
    }
  }
  
  private func updateOfferings() {
    isLoading = true
    Purchases.shared.getOfferings { [self] (offerings, error) in
      self.isLoading = false
      if let current = offerings?.current {
        self.offering = current
      } else if let updateError = error {
        updateError.localizedDescription.log()
        self.handle(updateError)
      }
    }
  }
  
  func handle(_ error: NSError) {
    (self.alertTitle, self.alertMessage) = ProductStore.parse(error)
    self.showAlert = true
  }
  
  static func parse(_ error: NSError) -> (String, String) {
    switch error.code {
    case 10: return (connectionFailure, networkError)
    case 2: return (connectionFailure, appStoreError)
    case 1: return (purchaseFailure, userCancelled)
    default: return (purchaseFailure, generalError)
    }
  }
}

// MARK: Static strings
extension ProductStore {  
  static var ENTITLEMENT_ID: String { "paid" }
  
  static var MONTHLY_ID: String { "$rc_monthly" }
  static var YEARLY_ID: String { "$rc_annual" }
  static var LIFETIME_ID: String { "$rc_lifetime" }
  
  static var paymentsNotAllowed: String { "Payments not allowed"}
  static var unauthorizedUser: String {
    "We are unable to process payments from this account. Kindly check your account information under App Store Settting and try again."
  }
  
  static var userCancelled: String {
    "We are sad to see you change your mind. Kindly send us your feedback.\n\nBy the way, Swimbols Lite is free forever with limited features. We hope you like it."
  }
  
  static var generalError: String {
    "We are unable to process your request at the moment. Please try again later."
  }
  
  static var purchaseFailure: String { "Purchase failed" }
  static var purchaseExpiredTitle: String { "Purchase expired" }
  static var connectionFailure: String { "Connection failed" }
  static var networkError: String { "We are unable to connect to the App Store. Kindly check your internet connection and try again." }
  static var appStoreError: String { "We are unable to connect to App Store at the moment. Please try again later." }
  static var purchaseExpiredMessage: String {
    "We have noticed that your purchase has expired. Kindly purchase again to continue using all features and support the development of Swimbols."
  }
  
  //    static var MONTHLY_ID: String { "imthath_swimbols_month" }
  //    static var YEARLY_ID: String { "imthath_swimbols_yearly" }
  //    static var LIFETIME_ID: String { "imthath_swimbols_lifetime" }
}
