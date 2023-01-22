//
//  StaticViews.swift
//  SFCodePad
//
//  Created by Imthath M on 22/10/20.
//  Copyright © 2020 Imthath. All rights reserved.
//

import CanvasKit
import SwiftUI

struct IconText: View {
  var version: SwimbolVersion
  
  var body: some View {
    Image("app-icon")
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
    
    Text("also available on iPhone and iPad")
      .foregroundColor(.secondary)
      .multilineTextAlignment(.center)
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
      .frame(minWidth: 232, idealWidth: 400, maxWidth: .infinity,
             minHeight: 232, idealHeight: 400, maxHeight: .infinity)
  }
  
  func termsView() -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 15) {
        Text("Terms of Use")
          .font(.largeTitle)
          .centerHorizontally()
        Text("""
                        Swimbols provides a swifty and fun way to work with SF Symbols. Do the searching, designing and then changing symbols all in one place, and take your code with you.
                        
                        You can use Swimbols for free with limited features. You can upgrade to Swimbols Pro to unlock all features by opting for a monthly subscription or an yearly subscription. Initially, for a limited period, we are also providing a launch offer - a one time purchase.
                        
                        You can cancel anytime 24 hours before the end of the current period, so that you will not be charged for the next period.
                        """)
        
        Button("Contact us") {
          CustomApp.openURL("mailto:imthath.m@icloud.com?subject=\(subject.encoded)")
        }
        .centerHorizontally()
        
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
  }
  
  var subject: String { "Swimbols Terms of Use" }
}

struct FeaturesText: View {
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
          .multilineTextAlignment(.leading)
          .layoutPriority(1)
        Spacer()
      }
      topLabelSet
      bottomLabelSet
      
      if version == .lite {
        Button("Continue with Lite") {
          ProductStore.shared.state = .limited
        }
        
        HStack {
          Text("You can upgrade to Swimbols Pro anytime. The Pro upgrade includes everything in Lite and the following...")
            .fixedSize(horizontal: false, vertical: true)
          //                    .frame(minHeight: 60)
            .multilineTextAlignment(.leading)
            .layoutPriority(1)
          Spacer()
        }
        .padding(.top)
        HStack {
          favLabel
          codeLabel
        }
        
        Button("Upgrade now") {
          self.presentationMode.wrappedValue.dismiss()
        }
        //                .buttonStyle(CardButtonStyle(backgroundColor: Color(.secondarySystemGroupedBackground), textColor: .pink))
        
      }
      secondaryButtons
    }
    .foregroundColor(Color.primary.opacity(0.9))
    .padding(10)
  }
  
  @ViewBuilder var secondaryButtons: some View {
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
    
    Text("Close")
      .foregroundColor(.secondary)
      .onTapGesture {
        Router.shared.splitVC.host.dismiss(Router.shared.splitVC.host)
      }
      .centerHorizontally()
  }
  
  @ViewBuilder var topLabelSet: some View {
    colorLabel(title: "Browse and search SF Symbols", andImage: "doc.text.magnifyingglass", with: Color.yellow.opacity(0.9))
    if version == .pro {
      favLabel
    }
    colorLabel(title: "See real time preview as you add, edit or delete modifiers", andImage: "play.fill", with: Color.green.opacity(0.9))
  }
  
  var favLabel: some View {
    colorLabel(title: "Add/Remove favorites and list them", andImage: "heart.fill", with: Color.red.opacity(0.8))
  }
  
  @ViewBuilder var bottomLabelSet: some View {
    colorLabel(title: "Scale your preview to help while designing", andImage: "rectangle.and.arrow.up.right.and.arrow.down.left", with: Color.purple.opacity(0.9))
    colorLabel(title: "Change symbol anytime and see live preview with applied modifiers", andImage: "photo.fill.on.rectangle.fill", with: Color.pink.opacity(0.8))
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
      Text(title)
        .layoutPriority(2)
        .lineLimit(nil)
    }
    .fixedSize(horizontal: false, vertical: true)
  }
}

struct FeaturesText_Previews: PreviewProvider {
  static var previews: some View {
    FeaturesText(version: .pro)
    //        LiteView()
  }
}
