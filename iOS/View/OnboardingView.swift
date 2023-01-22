//
//  OnboardingView.swift
//  SFCodePad
//
//  Created by Imthath M on 10/11/20.
//  Copyright © 2020 Imthath. All rights reserved.
//

import SwiftUI

struct OnboardingModel {
  var appName: String
  var details: [DetailModel]
  
  /// the height of the expected bottom sheet
  var bottomPadding: CGFloat = 300
  
  /// the background color for the entier onboarding view. Make sure it contrasts
  /// with the bottom sheet in iPhone
  var backgroundColor: Color = Color(.systemGroupedBackground)
  var secondaryBackgroundColor = Color(.secondarySystemGroupedBackground)
}

struct OnboardingView<Content>: View where Content: View {
  
  @Environment(\.horizontalSizeClass) var sizeClass
  var model: OnboardingModel
  var content: () -> Content
  
  var body: some View {
    adaptiveStack
      .background(model.backgroundColor.edgesIgnoringSafeArea(.all))
  }
  
  @ViewBuilder var adaptiveStack: some View {
    if #available(iOS 13.0, *),
       sizeClass == .compact {
      zApproach
    } else {
      fullStack
    }
  }
  
  var fullStack: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 30) {
        welcomeStack
          .padding(.vertical, 44)
        
        detailGrid
          .padding(.horizontal, 44)
      }
      .padding(.bottom, 44)
      content()
        .padding(.horizontal, 100)
    }
    .clipped()
  }
  
  var gridItem: GridItem {
    GridItem(.flexible(minimum: 100, maximum: 400), spacing: 50, alignment: .leading)
  }
  
  let columns = [
    GridItem(.flexible()),
    GridItem(.flexible()),
    GridItem(.flexible())
  ]
  
  var detailGrid: some View {
    LazyVGrid(columns: [gridItem, gridItem], spacing: 30, content: {
      detailLoop
    })
  }
  
  var zApproach: some View {
    ZStack(alignment: .bottom) {
      slidingView
      //                .edgesIgnoringSafeArea(.all)
      content()
        .padding(.bottom)
        .background(model.secondaryBackgroundColor)
        .cornerRadius(30, corners: [.topLeft, .topRight])
      //                .edgesIgnoringSafeArea(.all)
    }
    .edgesIgnoringSafeArea(.bottom)
  }
  
  var slidingView: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 30) {
        welcomeText
          .padding(.top, 44)
        
        detailStack
          .padding(.horizontal)
      }
      .padding(.bottom, model.bottomPadding)
    }
    .clipped()
  }
  
  var welcomeText: some View {
    HStack {
      Spacer()
      Text("Welcome to \n\(Text(model.appName).foregroundColor(.accentColor))")
        .bold()
        .font(.largeTitle)
      Spacer()
    }
  }
  
  var welcomeStack: some View {
    HStack {
      Spacer()
      VStack {
        Text("Welcome to").bold()
        Text("Swimbols").bold().foregroundColor(.accentColor)
      }
      .font(.largeTitle)
      Spacer()
    }
  }
  
  var detailStack: some View {
    VStack(alignment: .leading, spacing: 30) {
      detailLoop
    }
  }
  
  var detailLoop: some View {
    ForEach(model.details, id: \.imageName) { model in
      DetailView(model: model)
    }
  }
}

struct DetailModel {
  var title: String
  var description: String
  var imageName: String
  var imageColor: Color
}

struct DetailView: View {
  
  var model: DetailModel
  
  var body: some View {
    HStack(spacing: 10) {
      Image(systemName: model.imageName)
        .font(.largeTitle)
        .frame(width: 64, height: 64, alignment: .center)
      //                .foregroundColor(model.imageColor)
        .foregroundColor(.accentColor)
      
      VStack(alignment: .leading, spacing: 5) {
        Text(model.title)
          .bold()
        Text(model.description)
          .multilineTextAlignment(.leading)
          .foregroundColor(.secondary)
          .lineLimit(10)
          .layoutPriority(2)
      }
    }
  }
}

struct OnboardingView_Previews: PreviewProvider {
  
  static var detailModel: DetailModel {
    DetailModel(title: "Adjust preview scale", description: "The preview scale will size up the symbol to help you design pixel perfect symbols.", imageName: "rectangle.and.arrow.up.right.and.arrow.down.left", imageColor: Color.purple.opacity(0.9))
  }
  
  static var previews: some View {
    OnboardingView(model: OnboardingModel.current, content: {
      OnboardingSheet(showIAPview: .constant(false), secondaryButtonColor: OnboardingModel.current.backgroundColor)
    })
  }
}

extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape( RoundedCorner(radius: radius, corners: corners) )
  }
}

struct RoundedCorner: Shape {
  
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners
  
  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}
