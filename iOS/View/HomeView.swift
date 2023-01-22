//
//  HomeView.swift
//  SymbolCode
//
//  Created by Imthath M on 19/07/20.
//

import SwiftUI
import CanvasKit

struct MobileView: View {
  
  //    @State var store: ViewModel = SFPreferences.shared.model
  @State var isOpen = false
  let color: SystemColor = PadColor()
  @State var showFavOnly = false
  @State var searchText: String = ""
  
  @State var showCategories = false
  
  @ObservedObject var preferences: SFPreferences = .shared
  @Environment(\.horizontalSizeClass) var horizontalSizeClass
  //    @Environment(\.verticalSizeClass) var verticalSizeClass
  //    @State var showIAPview = false
  
  var cancelButton: Alert.Button {
    Alert.Button.cancel()
    //        Alert.Button.cancel(Text("Can"))
  }
  
  var upgradeButton: Alert.Button {
    Alert.Button.default(Text("Buy Pro"), action: {
      self.preferences.showIAPview = true
    })
  }
  
  func upgradeAlert() -> Alert {
    Alert(title: Text("Upgrade Swimbols?"), message: Text(alertMessage), primaryButton: upgradeButton, secondaryButton: cancelButton)
  }
  
  var alertMessage: String {
    "You are currently using Swimbols Lite. \n To save favorites, copy code, export pictures and support the continuous development of the app, please upgrade to Swimbols Pro."
  }
  
  var body: some View {
    mainView
      .sheet(isPresented: $preferences.showIAPview, content: {
        IAPphone(showCloseButton: true)
      })
      .alert(isPresented: $preferences.showUpgradeAlert, content: upgradeAlert)
    
    //        BottomSheetView(isOpen: $isOpen, maxHeight: 600) {
    //            NavigationView {
    //                VStack {
    //                    Spacer()
    //                    Text("Other sample")
    //                    Spacer()
    //                    NavigationLink(destination: Text("child view")) {
    //                        Text("Press me")
    //                    }
    //                    Spacer()
    //                }.navigationBarTitle("New Nav bar")
    //
    //            }
    //        }.edgesIgnoringSafeArea(.all)
  }
  
  //    var settingsButton: some View {
  //        NavigationLink(destination: Text("Settings"), label: {
  //            Image(systemSymbol: .gear).imageScale(.large)
  //        })
  //    }c
  
  @ViewBuilder var mainView: some View {
    if horizontalSizeClass == .regular {
      iPadView
    } else {
      iPhoneView
    }
  }
  
  var iPadView: some View {
    NavigationView {
      CategoryList(store: $preferences.model, color: color, showFavOnly: $showFavOnly, searchText: $searchText)
        .listStyle(SidebarListStyle())
      SymbolSelector(store: $preferences.model, color: color,
                     showFavOnly: $showFavOnly, searchText: $searchText)
      
      //            SymbolAndOutput(model: $preferences.model)
      //            .inShortWindow
      //            ModifiersForm(model: $preferences.model, addEditButton: true)
      //                .inSmallWindow
      
      HomeView(store: $preferences.model, color: color)
        .navigationBarTitle("Swimbols")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: SWSettingsView())
      //                .disabled(preferences.icon == nil)
      
    }
  }
  
  @State var selection: Int = 0
  var iPhoneView: some View {
    AdaptiveStack {
      SymbolView(model: $preferences.model, showsMoreOptions: true)
      //                .contentShape(Rectangle())
      //                .contextMenu {
      //                    Button("Copy SwiftUI code") {
      //                        preferences.code = .swiftUI
      //                        preferences.copyCode()
      //                    }
      //                    Button("Copy UIKit code") {
      //                        preferences.code = .uiKit
      //                        preferences.copyCode()
      //                    }
      //                }
      
      Divider()
      NavigationView {
        navBody
          .edgesIgnoringSafeArea(.bottom)
          .navigationBarTitle("")
          .navigationBarHidden(true)
      }
      
    }
  }
  
  @ViewBuilder var navBody: some View {
    if preferences.icon == nil {
      symbolSelector
    } else {
      propertiesStack
    }
  }
  var propertiesStack: some View {
    VStack(spacing: .zero) {
      Picker("", selection: $selection) {
        Text("Symbols").tag(0)
        Text("Modifiers").tag(1)
        Text("Code").tag(2)
      }
      .pickerStyle(SegmentedPickerStyle())
      .padding(.small)
      if selection == 0 {
        symbolSelector
      } else if selection == 1 {
        ModifiersForm(model: $preferences.model, addEditButton: true)
          .textFieldStyle(RoundedBorderTextFieldStyle())
      } else {
        SymbolOutput(store: $preferences.model)
          .padding(EdgeInsets(top: .small, leading: .medium, bottom: .medium, trailing: .medium))
      }
    }
  }
  
  var categoriesButton: some View {
    Button("Categories") {
      self.showCategories = true
    }
  }
  
  //    var categoryList: some View {
  //        NavigationView {
  //            CategoryList(store: $preferences.model, color: color, showFavOnly: $showFavOnly, searchText: $searchText)
  ////                .navigationBarTitle("Categories")
  ////                .navigationBarTitleDisplayMode(.inline)
  //        }
  //    }
  
  var symbolSelector: some View {
    SymbolSelector(store: $preferences.model, color: color,
                   showFavOnly: $showFavOnly, searchText: $searchText, showButtonsNearSearchField: true)
  }
  
  var symbolsTitle: String {
    if !searchText.isEmpty { return "Search Results" }
    
    if showFavOnly { return "Favorites" }
    
    if let cat = preferences.category { return cat.title }
    
    return "SF Symbols"
  }
}

public struct AdaptiveStack<Content: View>: View {
  
  @Environment(\.verticalSizeClass) var verticalSizeClass
  
  var content: Content
  
  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }
  
  public var body: some View {
    if verticalSizeClass == .regular {
      VStack {
        content
      }
    } else {
      HStack {
        content
      }
    }
  }
}
