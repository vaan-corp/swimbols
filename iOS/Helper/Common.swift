//
//  Common.swift
//  SFCodePad
//
//  Created by Imthath M on 19/07/20.
//  Copyright © 2020 Imthath. All rights reserved.
//

import CanvasKit
import SwiftUI

class PadColor: SystemColor {
  var textBackground: Color { Color(.secondarySystemBackground) }
  
  var tertiaryLabel: Color { Color(.tertiaryLabel) }
}

public struct CardButtonStyle: ButtonStyle {
  let backgroundColor: Color
  let textColor: Color
  let height: CGFloat
  
  public init(backgroundColor: Color = .accentColor,
              textColor: Color = .white,
              height: CGFloat = .averageTouchSize * 1.25) {
    self.backgroundColor = backgroundColor
    self.textColor = textColor
    self.height = height
  }
  
  public func makeBody(configuration: Configuration) -> some View {
    ZStack {
      bgColor(for: configuration).cornerRadius(.small)
      configuration.label
        .foregroundColor(self.fgColor(for: configuration))
    }
    .frame(height: height)
    .padding(.vertical, .small)
  }
  
  func fgColor(for configuration: Configuration) -> Color {
    configuration.isPressed ? textColor.opacity(0.6) : textColor
  }
  
  func bgColor(for configuration: Configuration) -> Color {
    configuration.isPressed ? backgroundColor.opacity(0.3) : backgroundColor
  }
}

public struct ActivityIndicator: UIViewRepresentable {
  @Binding var isAnimating: Bool
  let style: UIActivityIndicatorView.Style
  
  public func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
    return UIActivityIndicatorView(style: style)
  }
  
  public func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
    if isAnimating {
      uiView.startAnimating()
    } else {
      uiView.stopAnimating()
    }
  }
}

public extension ActivityIndicator {
  static var large: some View {
    ActivityIndicator(isAnimating: .constant(true), style: .large)
  }
}

extension View {
  func simpleAlert(isPresented: Binding<Bool>, title: String = "Alert", message: String) -> some View {
    return self.alert(isPresented: isPresented, content: {
      Alert(title: Text(title), message: Text(message))
    })
  }
  
  @ViewBuilder func alternateLoader(on isLoading: Binding<Bool>, withPadding padding: CGFloat = .zero) -> some View {
    if isLoading.wrappedValue {
      ActivityIndicator.large
        .padding(padding)
    } else {
      self
    }
  }
}

#if canImport(UIKit)
class AnyGestureRecognizer: UIGestureRecognizer {
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
    if let touchedView = touches.first?.view, touchedView is UIControl {
      state = .cancelled
    } else if let touchedView = touches.first?.view as? UITextView, touchedView.isEditable {
      state = .cancelled
    } else {
      state = .began
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    state = .ended
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
    state = .cancelled
  }
}

extension SceneDelegate: UIGestureRecognizerDelegate {
  func addTapGestrureRecognizer() {
    let tapGesture = AnyGestureRecognizer(target: window, action: #selector(UIView.endEditing))
    tapGesture.requiresExclusiveTouchType = false
    tapGesture.cancelsTouchesInView = false
    tapGesture.delegate = self
    window?.addGestureRecognizer(tapGesture)
  }
  
  func gestureRecognizer(
    _ gestureRecognizer: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
  ) -> Bool {
    return true
  }
}

extension View {
  func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}
#endif

extension String {
  internal func log(file: String = #file,
                    functionName: String = #function,
                    lineNumber: Int = #line) {
    let url = URL(fileURLWithPath: file).lastPathComponent
    print("[SWIMBOLS_\(UIDevice.isPad ?  "iPad" : "iPhone")] \(url)-\(functionName):\(lineNumber)  \(self)")
  }
}

#if DEBUG
import SwiftUI

struct PreviewProviderModifier: ViewModifier {
  /// Whether or not a basic light mode preview is included in the group.
  var includeLightMode: Bool
  
  /// Whether or not a basic dark mode preview is included in the group.
  var includeDarkMode: Bool
  
  /// Whether or not right-to-left layout preview is included in the group.
  var includeRightToLeftMode: Bool
  
  /// Whether or not a preview with large text is included in the group.
  var includeLargeTextMode: Bool
  
  func body(content: Content) -> some View {
    Group {
      if includeLightMode {
        content
          .previewDisplayName("Light Mode")
          .environment(\.colorScheme, .light)
      }
      
      if includeDarkMode {
        content
          .previewDisplayName("Dark Mode")
          .environment(\.colorScheme, .dark)
      }
      
      if includeRightToLeftMode {
        content
          .previewDisplayName("Right To Left")
          .environment(\.layoutDirection, .rightToLeft)
      }
      
      if includeLargeTextMode {
        content
          .previewDisplayName("Large Text")
          .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
      }
    }
  }
}

extension View {
  /// Creates a group of views with various environment settings that are useful for previews.
  ///
  /// - Parameters:
  ///   - includeLightMode: Whether or not a basic light mode preview is included in the group.
  ///   - includeDarkMode: Whether or not a basic dark mode preview is included in the group.
  ///   - includeRightToLeftMode: Whether or not a right-to-left layout preview is included in the group.
  ///   - includeLargeTextMode: Whether or not a preview with large text is included in the group.
  func makeForPreviewProvider(
    includeLightMode: Bool = true,
    includeDarkMode: Bool = true,
    includeRightToLeftMode: Bool = true,
    includeLargeTextMode: Bool = true
  ) -> some View {
    modifier(
      PreviewProviderModifier(
        includeLightMode: includeLightMode,
        includeDarkMode: includeDarkMode,
        includeRightToLeftMode: includeRightToLeftMode,
        includeLargeTextMode: includeLargeTextMode
      )
    )
  }
}
#endif
