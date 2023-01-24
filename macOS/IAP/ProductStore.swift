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
import StoreKit

enum ProductState: Int {
  case installed = 0
  case transacted = 1
  case restored = 2
  case purchased = 3
  case expired = 4
  case limited = 5
}

extension ProductState {
  @CVDefault("productStateEnum", defaultValue: 5)
  static var storedRawValue: Int
  
  @CVDefault("activeSessions", defaultValue: 0)
  static var activeSessions: Int64
  
  static var storedValue: ProductState { ProductState(rawValue: storedRawValue) ?? .limited }
  
  static func updateCount() {
    var count = ProductState.activeSessions
    count += 1
    "Session #\(count)".log()
    ProductState.activeSessions = count
    
    if count % 50 == 0 {
      SKStoreReviewController.requestReview()
    }
  }
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
  
  var isTrial: Bool { state != .purchased }
  
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
      if let paidEntitlement = info?.entitlements[ProductStore.entitlementIdentifier] {
        "\(paidEntitlement)".log()
        if paidEntitlement.isActive {
          if !self.isPurchased {
            "Updating user payment".log()
            self.state = .purchased
          } else {
            "Continuing as paid user".log()
          }
        } else {
          "Purchased expired on - \(paidEntitlement.expirationDate?.description ?? "Date not found")".log()
          self.state = .expired
          self.alertTitle = ProductStore.purchaseExpiredTitle
          self.alertMessage = ProductStore.purchaseExpiredMessage
          self.showAlert = true
        }
      } else if let updateError = error as NSError? {
        updateError.localizedDescription.log()
        self.handle(updateError)
      } else {
        "No entitlements found in purchaser info".log()
        if self.state != .limited {
          "Change state from \(self.state) to limted".log()
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
        //                self.packages = current.availablePackages
      } else if let updateError = error as NSError? {
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
  static var entitlementIdentifier: String { "paid" }
  
  static var monthlyIdentifier: String { "$rc_monthly" }
  static var yearlyIdentifier: String { "$rc_annual" }
  static var lifetimeIdentifier: String { "$rc_lifetime" }
  
  //    static var accountError: St
  static var paymentsNotAllowed: String { "Payments not allowed"}
  static var unauthorizedUser: String {
    """
    We are unable to process payments from this account. \
    Kindly check your account information under App Store Settting and try again.
    """
  }
  
  //    static var whatSt
  static var userCancelled: String {
    """
    We are sad to see you change your mind and not continue with the purchase. \
    Kindly send us your feedback to let us know on how to improve.
    """
  }
  
  static var generalError: String { "We are unable to process your request at the moment. Please try again later." }
  //    static var paidUser: String { }
  
  static var purchaseFailure: String { "Purchase failed" }
  static var purchaseExpiredTitle: String { "Purchase expired" }
  static var connectionFailure: String { "Connection failed" }
  static var networkError: String {
    "We are unable to connect to the App Store. Kindly check your internet connection and try again."
  }
  static var appStoreError: String { "We are unable to connect to App Store at the moment. Please try again later." }
  static var purchaseExpiredMessage: String {
    "We have noticed that your purchase has expired. Kindly purchase again to continue using and supporting Swimbols."
  }
  
  //    static var MONTHLY_ID: String { "imthath_swimbols_month" }
  //    static var YEARLY_ID: String { "imthath_swimbols_yearly" }
  //    static var LIFETIME_ID: String { "imthath_swimbols_lifetime" }
}
