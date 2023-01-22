//
//  StaticViews.swift
//  SFCodePad
//
//  Created by Imthath M on 22/10/20.
//  Copyright © 2020 Imthath. All rights reserved.
//

import SwiftUI
import CanvasKit

struct PriceCard: View {
  
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  
  var price: String
  var duration: String
  var description: String
  var color: Color
  
  //    init(price: String, duration: String, description: String, color: Color) {
  //
  //    }
  var body: some View {
    VStack(alignment: .center, spacing: 5.0) {
      HStack(alignment: .center, spacing: 0.0) {
        Text(price)
          .font(.title2)
          .bold()
      }
      HStack {
        Spacer()
      }
      Text(duration.lowercased())
        .foregroundColor(Color(UIColor.secondaryLabel))
      //                .font(.footnote)
      Text(description)
      //                    .font(.footnote)
        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        .background(color)
        .clipShape(Capsule())
        .padding([.top], 10)
        .layoutPriority(2)
      if horizontalSizeClass == .regular {
        Spacer()
      }
    }
    .padding(EdgeInsets(top: 10.0, leading: 10.0, bottom: 10.0, trailing: 10.0))
    .background(Color(UIColor.secondarySystemGroupedBackground))
    .cornerRadius(10.0)
    .padding(EdgeInsets(top: 0.0, leading: 5.0, bottom: 0.0, trailing: 5.0))
    //        .redacted(reason: .placeholder)
  }
}

public struct PurchaseCompletedView: View {
  
  //    var isRestored: Bool
  @ObservedObject var productStore = ProductStore.shared
  @Environment(\.presentationMode ) var presentationMode
  
  public var body: some View {
    ScrollView {
      viewStack
    }
    .clipped()
    .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
  }
  
  var viewStack: some View {
    VStack(spacing: .averageTouchSize) {
      Image(systemName: "gift.circle.fill")
        .renderingMode(.original)
        .font(.system(size: 120))
      //                .padding(.large)
      //                .background(Color.red.cornerRadius(.medium))
        .padding(.top)
      Text("Thank you for \(productStore.state == .restored ? "continuing with us" : "purchasing")!")
        .font(.largeTitle)
      textGroup
      Button("Continue") {
        productStore.state = .purchased
        self.presentationMode.wrappedValue.dismiss()
      }.buttonStyle(CardButtonStyle())
    }
    .padding()
    .multilineTextAlignment(.center)
  }
  
  var textGroup: some View {
    VStack(spacing: .large) {
      //            Spacer()
      Text("We are continuously striving to improve your workflow and productivity when working with SF Symbols.  ")
      //            Spacer()
      Text("If you face any issue or would like a new feature, kindly contact us at imthath.m@icloud.com.")
      //            Spacer()
      Text("We value your feedback and we are committed to respond within 3 days.")
      //            Spacer()
    }
  }
}

struct IconText: View {
  
  var version: SwimbolVersion
  
  var body: some View {
    Image("cornerFilled")
      .resizable()
      .scaledToFill()
      .frame(width: 96, height: 96, alignment: .center)
      .padding()
    
    HStack {
      Spacer()
      Text("Swimbols \(proText)")
        .font(.largeTitle)
      Spacer()
    }
    
    Text("also available on \(UIDevice.isPad ? "iPhone" : "iPad") and Mac")
      .foregroundColor(.secondary)
      .multilineTextAlignment(.center)
      .padding(.bottom, 30)
  }
  
  var proText: Text {
    Text(version.name)
      .fontWeight(version.fontWeight)
      .foregroundColor(.pink)
  }
}

struct TermsView: View {
  @Environment(\.presentationMode) var presentationMode
  
  var body: some View {
    termsView()
  }
  
  func termsView() -> some View {
    NavigationView {
      ScrollView {
        VStack(alignment: .leading, spacing: 15) {
          Text("""
                        Swimbols provides a swifty and fun way to work with SF Symbols. Do the searching, designing and then changing symbols all in one place, and take your code with you.
                        
                        You can use Swimbols Lite for free with limited features. You can upgrade to Swimbols Pro to unlock all features by opting for a monthly subscription or an yearly subscription. Initially, for a limited period, we are also providing a launch offer - a one time purchase.
                        
                        You can cancel anytime 24 hours before the end of the current period, so that you will not be charged for the next period.
                        """)
          
          Button("Contact us") {
            CustomApp.openURL("mailto:imthath.m@icloud.com?subject=\(subject.encoded)")
          }
          .buttonStyle(CardButtonStyle())
          
          HStack {
            Spacer()
            Text("Close")
              .foregroundColor(.secondary)
              .onTapGesture {
                presentationMode.wrappedValue.dismiss()
              }
            Spacer()
          }
          
        }
        .padding()
      }
      
      .navigationBarTitle("Terms of Use", displayMode: .inline)
    }
  }
  
  var subject: String { "Swimbols Terms of Use" }
}

struct FeaturesText: View {
  
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  @Environment(\.presentationMode) var presentationMode
  
  @State var showTerms = false
  
  var version: SwimbolVersion
  
  var body: some View {
    featuresText
      .sheet(isPresented: $showTerms, content: { TermsView() })
  }
  
  var featuresText: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack {
        Text("Swimbols \(version.name) can help you do the following and more...")
          .fixedSize(horizontal: false, vertical: true)
        //                    .frame(minHeight: 60)
          .multilineTextAlignment(.leading)
          .layoutPriority(1)
        Spacer()
      }
      
      if horizontalSizeClass == .regular {
        HStack {
          VStack(alignment: .leading, spacing: 15) {
            topLabelSet
          }
          
          VStack(alignment: .leading, spacing: 15) {
            bottomLabelSet
          }
        }
      } else {
        topLabelSet
        bottomLabelSet
      }
      
      if version == .lite {
        Button("Continue with Lite") {
          ProductStore.shared.state = .limited
        }
        .buttonStyle(CardButtonStyle(backgroundColor: Color(.secondarySystemGroupedBackground), textColor: .primary)).opacity(0.75)
        
        HStack {
          Text("You can upgrade to Swimbols Pro anytime. The Pro upgrade includes everything in Lite and the following...")
            .fixedSize(horizontal: false, vertical: true)
          //                    .frame(minHeight: 60)
            .multilineTextAlignment(.leading)
            .layoutPriority(1)
          Spacer()
        }
        .padding(.top)
        
        if horizontalSizeClass == .regular {
          HStack {
            favLabel
            codeLabel
          }
        } else {
          favLabel
          codeLabel
        }
        
        Button("Upgrade now") {
          self.presentationMode.wrappedValue.dismiss()
        }
        .buttonStyle(CardButtonStyle(backgroundColor: Color(.secondarySystemGroupedBackground), textColor: .accentColor))
        
      }
      secondaryButtons.padding(.top)
    }
    .foregroundColor(Color.primary.opacity(0.9))
    .padding(10)
  }
  
  var secondaryButtons: some View {
    HStack {
      Spacer()
      Text("Terms of Use")
        .underline()
        .foregroundColor(.secondary)
        .onTapGesture {
          self.showTerms = true
        }
      Spacer()
      Text("Privacy Policy")
        .underline()
        .foregroundColor(.secondary)
        .onTapGesture {
          CustomApp.openURL("https://imthath-m.github.io/swimbols")
        }
      Spacer()
    }
  }
  
  @ViewBuilder var topLabelSet: some View {
    colorLabel(title: "Browse and search SF Symbols", andImage: "doc.text.magnifyingglass", with: Color.yellow.opacity(0.9))
    if version == .pro {
      favLabel
    }
    
    //            colorLabel(title: "Select and modify symbols with SwiftUI modifiers", andImage: "wand.and.stars", with: Color.blue.opacity(0.8))
    colorLabel(title: "See real time preview as you add, edit or delete modifiers", andImage: "play.fill", with: Color.green.opacity(0.9))
  }
  
  var favLabel: some View {
    colorLabel(title: "Add/Remove favorites and list them", andImage: "heart.fill", with: Color.red.opacity(0.8))
  }
  
  @ViewBuilder var bottomLabelSet: some View {
    colorLabel(title: "Scale your preview to help while designing", andImage: "rectangle.and.arrow.up.right.and.arrow.down.left", with: Color.purple.opacity(0.9))
    colorLabel(title: "Change symbol anytime and see live preview with applied modifiers", andImage: "photo.on.rectangle.angled", with: Color.pink.opacity(0.8))
    if version == .pro {
      codeLabel
    }
  }
  
  var codeLabel: some View {
    colorLabel(title: "Copy Swift code to use in your SwiftUI and UIKit projects", andImage: "curlybraces", with: Color.blue.opacity(0.8))
  }
  
  func colorLabel(title: String, andImage imageName: String, with color: Color) -> some View {
    HStack(spacing: 10) {
      Image(systemName: imageName)
        .frame(minWidth: 36, minHeight: 36)
        .imageScale(.large)
        .padding(5)
        .background(color)
        .cornerRadius(5)
        .foregroundColor(.white)
      //                .foregroundColor(Color(.systemBackground))
      Text(title)
        .layoutPriority(2)
        .lineLimit(nil)
      //            if horizontalSizeClass == .regular {
      //                Spacer()
      //            }
    }
    .fixedSize(horizontal: false, vertical: true)
    //        .frame(minHeight: 60)
  }
}

struct PurchaseCompleted_Previews: PreviewProvider {
  static var previews: some View {
    PurchaseCompletedView()
  }
}
