//
//  ViewAlignment.swift
//  Swimbols
//
//  Created by Imthathullah M on 01/10/20.
//

import Cocoa

public extension NSView {
  
  @discardableResult func align(_ type1: NSLayoutConstraint.Attribute,
                                with view: NSView? = nil, on type2: NSLayoutConstraint.Attribute? = nil,
                                offset constant: CGFloat = 0,
                                priority: Float? = nil, useSafeAreaOnly: Bool = true) -> NSLayoutConstraint? {
    guard let view = view ?? superview else {
      return nil
    }
    
    let layoutGuide: Any = useSafeAreaOnly ? view.safeAreaLayoutGuide : view
    let type2 = type2 ?? type1
    
    translatesAutoresizingMaskIntoConstraints = false
    
    let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                        relatedBy: .equal,
                                        toItem: layoutGuide, attribute: type2,
                                        multiplier: 1, constant: constant)
    if let priority = priority {
      constraint.priority = NSLayoutConstraint.Priority.init(priority)
    }
    
    constraint.isActive = true
    
    return constraint
  }
  
  func alignEdges(with view: NSView? = nil, offset constant: CGFloat = 0) {
    align(.top, with: view, offset: constant)
    align(.bottom, with: view, offset: -constant)
    align(.leading, with: view, offset: constant)
    align(.trailing, with: view, offset: -constant)
  }
  
  func align(greaterThanHeight height: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual,
                                     toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
  }
  
  func alignHorizontally(with view: NSView? = nil, offset constant: CGFloat = 0) {
    align(.leading, with: view, offset: constant)
    align(.trailing, with: view, offset: -constant)
  }
  
  func alignVertically(with view: NSView? = nil, offset constant: CGFloat = 0) {
    align(.top, with: view, offset: constant)
    align(.bottom, with: view, offset: -constant)
  }
  
  func alignTop(with view: NSView? = nil, offset constant: CGFloat = 0) {
    align(.top, with: view, offset: constant)
    align(.leading, with: view, offset: constant)
    align(.trailing, with: view, offset: -constant)
  }
  
  func alignBottom(with view: NSView? = nil, offset constant: CGFloat = 0) {
    align(.bottom, with: view, offset: -constant)
    align(.leading, with: view, offset: constant)
    align(.trailing, with: view, offset: -constant)
  }
  
  func alignCenter(with view: NSView? = nil, offset constant: CGFloat = 0) {
    align(.centerX, with: view)
    align(.centerY, with: view)
  }
  
  func alignLeading(with view: NSView? = nil, offset constant: CGFloat = 0) {
    align(.top, with: view, offset: constant)
    align(.bottom, with: view, offset: -constant)
    align(.leading, with: view, offset: constant)
  }
  
  func alignTrailing(with view: NSView? = nil, offset constant: CGFloat = 0) {
    align(.top, with: view, offset: constant)
    align(.bottom, with: view, offset: -constant)
    align(.trailing, with: view, offset: -constant)
  }
  
  func align(_ attributes: [NSLayoutConstraint.Attribute], with view: NSView? = nil, offset constant: CGFloat = 0) {
    for attribute in attributes {
      align(attribute, with: view, offset: constant)
    }
  }
}

// fixing sizes
public extension NSView {
  
  enum SizeAttribute {
    case height
    case width
  }
  
  func fixSize(_ size: CGSize) {
    fixWidth(size.width)
    fixHeight(size.height)
  }
  
  func fixWidth(_ width: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    self.widthAnchor.constraint(equalToConstant: width).isActive = true
  }
  
  func fixHeight(_ height: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    self.heightAnchor.constraint(equalToConstant: height).isActive = true
  }
  
  func minWidth(_ width: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    self.widthAnchor.constraint(greaterThanOrEqualToConstant: width).isActive = true
  }
  
  func maxWidth(_ width: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    self.widthAnchor.constraint(lessThanOrEqualToConstant: width).isActive = true
  }
  
  
  func minHeight(_ width: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    self.heightAnchor.constraint(greaterThanOrEqualToConstant: width).isActive = true
  }
  
  func maxHeight(_ width: CGFloat) {
    translatesAutoresizingMaskIntoConstraints = false
    self.heightAnchor.constraint(lessThanOrEqualToConstant: width).isActive = true
  }
  
  //    func setContentSize(along axis: NSLayoutConstraint.Axis) {
  //        setContentHuggingPriority(.defaultHigh, for: axis)
  //        setContentCompressionResistancePriority(.defaultHigh, for: axis)
  //    }
  
  func make(_ sizeAttribute: SizeAttribute, fraction multiplier: CGFloat = 1, as view: NSView, offset: CGFloat = 0) {
    self.getAnchor(for: sizeAttribute).constraint(equalTo: view.getAnchor(for: sizeAttribute),
                                                  multiplier: multiplier, constant: offset).isActive = true
  }
  
  private func getAnchor(for sizeAttribute: SizeAttribute) -> NSLayoutDimension {
    switch sizeAttribute {
    case .height:
      return self.heightAnchor
    case .width:
      return self.widthAnchor
    }
  }
  
  /// updates the semantic content attribute direction for this view based on the SDK language
  //    func updateLayoutDirection() {
  //        if NSView.isForcedRTL {
  //            semanticContentAttribute = .forceRightToLeft
  //        } else {
  //            semanticContentAttribute = .forceLeftToRight
  //        }
  //    }
}

// alignment for notched displays, iOS 11+
public extension NSView {
  
  //    enum SideAttribute {
  //        case leading
  //        case trailing
  //        case top
  //        case bottom
  //    }
  func alignSafe(with view: NSView) {
    let guide = view.getLayoutGuide()
    self.translatesAutoresizingMaskIntoConstraints = false
    self.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
    self.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
    self.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
    self.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
  }
  
  func alignTopSafe(with view: NSView) {
    let guide = view.getLayoutGuide()
    self.translatesAutoresizingMaskIntoConstraints = false
    self.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
    self.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
    self.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
  }
  
  func alignBottomSafe(with view: NSView) {
    let guide = view.getLayoutGuide()
    self.translatesAutoresizingMaskIntoConstraints = false
    self.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
    self.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
    self.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
  }
  
  func alignLeadingSafe(with view: NSView) {
    let guide = view.getLayoutGuide()
    self.translatesAutoresizingMaskIntoConstraints = false
    self.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
    self.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
    self.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
  }
  
  func alignTrailingSafe(with view: NSView) {
    let guide = view.getLayoutGuide()
    self.translatesAutoresizingMaskIntoConstraints = false
    self.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
    self.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
    self.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
  }
  
  func getLayoutGuide() -> NSLayoutGuide {
    //        if #available(iOS 11.0, *) {
    //            return self.safeAreaLayoutGuide
    //        }
    
    return self.safeAreaLayoutGuide
  }
  
  var safeRect: CGRect { self.safeAreaRect }
  
  var safeHeight: CGFloat { safeRect.height }
  
  var safeWidth: CGFloat { safeRect.width }
  
  var smallSide: CGFloat {
    safeRect.width < safeRect.height ? safeRect.width : safeRect.height
  }
}
