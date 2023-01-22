//
//  FirstScreen.swift
//  Swimbols-iOS
//
//  Created by Imthathullah on 22/01/23.
//  Copyright © 2023 Vaan Corporation. All rights reserved.
//

import SwiftUI

struct FirstScreen: View {
  @ObservedObject var productStore = ProductStore.shared

  var body: some View {
    currentView
      .accentColor(.pink)
  }

  @ViewBuilder var currentView: some View {
    switch productStore.state {
    case .installed: OnboardingWrapper()
    case .expired: IAPphone()
    case .transacted, .restored: PurchaseCompletedView()
    case .purchased, .limited: MobileView()
    }
  }
}

struct OnboardingWrapper: View {
  @State var showIAPview = false

  var body: some View {
    onboarding
  }

  var onboarding: some View {
    OnboardingView(model: OnboardingModel.current, content: {
      OnboardingSheet(showIAPview: $showIAPview, secondaryButtonColor: OnboardingModel.current.backgroundColor)
    })
  }
}


struct FirstScreen_Previews: PreviewProvider {
    static var previews: some View {
        FirstScreen()
    }
}
