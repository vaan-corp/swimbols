//
//  OnboardingButtons.swift
//  SFCodePad
//
//  Created by Imthath M on 11/11/20.
//  Copyright © 2020 Imthath. All rights reserved.
//

import SwiftUI

struct OnboardingSheet: View {
  @Environment(\.horizontalSizeClass) var sizeClass
  @State var showMobileView = false
  @Binding var showIAPview: Bool
  var secondaryButtonColor: Color
  var body: some View {
    adaptiveStack
  }
  
  @ViewBuilder var adaptiveStack: some View {
    if #available(iOS 13.0, *),
       sizeClass == .compact {
      VStack {
        liteGroup
        purchaseGroup
      }
      .padding()
    } else {
      HStack {
        VStack {
          liteGroup
        }
        VStack {
          purchaseGroup
        }
      }
      .padding(.horizontal, 20)
      .padding(.bottom, 100)
    }
  }
  
  @ViewBuilder var liteGroup: some View {
    //                Text("You can use Swimbols Lite for free with a subset of the above mentioned features.")
    let liteButtonStyle = CardButtonStyle(
      backgroundColor: sizeClass == .compact ? secondaryButtonColor : Color(.secondarySystemGroupedBackground),
      textColor: .primary
    )
    Text("Free lite version with limited features")
      .foregroundColor(.secondary)
      .font(.footnote)
    Button("Continue with Lite") {
      ProductStore.shared.state = .limited
    }
    .buttonStyle(liteButtonStyle)
    .padding(.horizontal, 22)
  }
  
  @ViewBuilder var purchaseGroup: some View {
    //                Text("Get the most out of Swimbols with the Pro version. All the above features included and more.")
    Text("Full featured Pro version for the best experience")
      .foregroundColor(.secondary)
      .font(.footnote)
    Button("Purchase Pro") {
      self.showIAPview = true
    }
    .buttonStyle(CardButtonStyle(backgroundColor: .accentColor, textColor: .white, height: 55)).padding(.horizontal, 22)
    .sheet(isPresented: $showIAPview, content: { IAPphone(showCloseButton: true) })
  }
}

extension OnboardingModel {
  static var current: OnboardingModel {
    OnboardingModel(appName: "Swimbols", details: DetailModel.data, bottomPadding: 300,
                    backgroundColor: Color(.systemGroupedBackground),
                    secondaryBackgroundColor: Color(.secondarySystemGroupedBackground))
  }
}

extension DetailModel {
  static var data: [DetailModel] {
    [
      // swiftlint:disable line_length
      DetailModel(title: "Browse or search symbols", description: "Find the right symbol to use in your app by browsing through the categories or using the search bar.", imageName: "doc.text.magnifyingglass", imageColor: Color.yellow),
      DetailModel(title: "Customize with Modifiers", description: "Select and design any SF symbol to suit your app's needs by using the available modifiers.", imageName: "slider.horizontal.3", imageColor: Color.blue),
      DetailModel(title: "Live preview", description: "See real time preview as you add, edit, reorder or delete modifiers. Change symbols with a single tap and the preview never stops.", imageName: "play.rectangle", imageColor: Color.green.opacity(0.9)),
      //            DetailModel(title: "Instant switches", description: "Change the symbol anytime with just a tap. All the selected modifiers are applied to this new symbol and the preview never stops.", imageName: "photo.on.rectangle.angled", imageColor: Color.green),
      DetailModel(title: "Adjust preview scale", description: "The preview scale will size up the symbol to help you design pixel perfect symbols.", imageName: "rectangle.and.arrow.up.right.and.arrow.down.left", imageColor: Color.purple),
      DetailModel(title: "Code is the result", description: "You can copy the code of your designed symbol to use in your SwiftUI or UIKit project. The best handoff ever.", imageName: "curlybraces", imageColor: Color.orange),
      DetailModel(title: "Save your favorites", description: "Do you keep using some symbols often? Save them to your favorite list for instant access.", imageName: "heart", imageColor: Color.red),
      // swiftlint:enable line_length
    ]
  }
}

struct OnboardingButtons_Previews: PreviewProvider {
  static var previews: some View {
    OnboardingSheet(showIAPview: .constant(false), secondaryButtonColor: OnboardingModel.current.backgroundColor)
      .previewLayout(.sizeThatFits)
      .accentColor(.pink)
    //            .colorScheme(.dark)
    //            .makeForPreviewProvider(includeLightMode: true, includeDarkMode: true, includeRightToLeftMode: false, includeLargeTextMode: true)
  }
}
