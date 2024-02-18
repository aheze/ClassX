//
//  Utilities.swift
//  WhisperTest
//  
//  Created by Andrew Zheng (github.com/aheze) on 2/18/24.
//  Copyright © 2024 Andrew Zheng. All rights reserved.
//

import SwiftUI

enum Utilities {}

extension Utilities {
    static func interpolate(a: Double, b: Double, percent: Double) -> Double {
        let track = b - a
        let value = a + (track * percent)
        return value
    }
    
    static func interpolate(a: CGFloat, b: CGFloat, percent: CGFloat) -> CGFloat {
        let track = b - a
        let value = a + (track * percent)
        return value
    }
    
    static func percentage(trackStart: Double, trackEnd: Double, value: Double, cap: Bool) -> Double {
        let value = (value - trackStart) / (trackEnd - trackStart)
        
        if cap {
            return min(max(0, value), 1)
        } else {
            return value
        }
    }
    
    static func percentage(trackStart: CGFloat, trackEnd: CGFloat, value: CGFloat, cap: Bool) -> CGFloat {
        let value = (value - trackStart) / (trackEnd - trackStart)
        
        if cap {
            return min(max(0, value), 1)
        } else {
            return value
        }
    }
}

extension UIView {
    func pinEdgesToSuperview() {
        guard let superview = superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor),
            self.rightAnchor.constraint(equalTo: superview.rightAnchor),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor),
            self.leftAnchor.constraint(equalTo: superview.leftAnchor)
        ])
    }
}

extension UIViewController {
    func addChildViewController(_ childViewController: UIViewController, in view: UIView) {
        addChild(childViewController)
        view.addSubview(childViewController.view)
        
        /// Configure child view
        childViewController.view.frame = view.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        /// Notify child view controller
        childViewController.didMove(toParent: self)
    }
    
    /// Add a child view controller inside a view with constraints.
    func embed(_ childViewController: UIViewController, in view: UIView) {
        addChild(childViewController)
        view.addSubview(childViewController.view)
        
        childViewController.view.pinEdgesToSuperview()
        
        /// Notify the child view controller.
        childViewController.didMove(toParent: self)
    }
    
    func removeChildViewController(_ childViewController: UIViewController) {
        /// Notify child view controller
        childViewController.willMove(toParent: nil)
        
        /// Remove child view from superview
        childViewController.view.removeFromSuperview()
        
        /// Notify child view controller again
        childViewController.removeFromParent()
    }
}

extension UIView {
    /// add a border to a view
    func addDebugBorders(_ color: UIColor, width: CGFloat = 0.75) {
        backgroundColor = color.withAlphaComponent(0.2)
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
}

extension Color {
    init(hex: Int, opacity: CGFloat = 1) {
        self.init(hex: UInt(hex), opacity: opacity)
    }
    
    init(hex: UInt, opacity: CGFloat = 1) {
        self.init(
            .displayP3,
            red: Double((hex & 0xFF0000) >> 16) / 255,
            green: Double((hex & 0x00FF00) >> 8) / 255,
            blue: Double(hex & 0x0000FF) / 255,
            opacity: opacity
        )
    }
}

/// from https://stackoverflow.com/a/68555127/14351818
extension View {
    func overlay<Target: View>(align originAlignment: Alignment, to targetAlignment: Alignment, @ViewBuilder of target: () -> Target) -> some View {
        let hGuide = HorizontalAlignment(Alignment.TwoSided.self)
        let vGuide = VerticalAlignment(Alignment.TwoSided.self)
        
        return alignmentGuide(hGuide) { $0[originAlignment.horizontal] }
            .alignmentGuide(vGuide) { $0[originAlignment.vertical] }
            .overlay(alignment: Alignment(horizontal: hGuide, vertical: vGuide)) {
                target()
                    .alignmentGuide(hGuide) { $0[targetAlignment.horizontal] }
                    .alignmentGuide(vGuide) { $0[targetAlignment.vertical] }
            }
    }
}

extension Alignment {
    enum TwoSided: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat { 0 }
    }
}


public extension View {
    /// Read a view's frame. From https://stackoverflow.com/a/66822461/14351818
    func frameReader(in coordinateSpace: CoordinateSpace = .global, frame: @escaping (CGRect) -> Void) -> some View {
        return background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ContentFrameReaderPreferenceKey.self, value: geometry.frame(in: coordinateSpace))
                    .onPreferenceChange(ContentFrameReaderPreferenceKey.self) { newValue in
                        frame(newValue)
                    }
            }
            .hidden()
        )
    }

    /// Read a view's size. From https://stackoverflow.com/a/66822461/14351818
    func sizeReader(size: @escaping (CGSize) -> Void) -> some View {
        return background(
            GeometryReader { geometry in
                Color.clear
                    .preference(key: ContentSizeReaderPreferenceKey.self, value: geometry.size)
                    .onPreferenceChange(ContentSizeReaderPreferenceKey.self) { newValue in
                        size(newValue)
                    }
            }
            .hidden()
        )
    }
}

struct ContentFrameReaderPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect { return CGRect() }
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) { value = nextValue() }
}

struct ContentSizeReaderPreferenceKey: PreferenceKey {
    static var defaultValue: CGSize { return CGSize() }
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) { value = nextValue() }
}

public extension View {
    @inlinable
    func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        padding: CGFloat = 0, /// extra negative padding for shadows
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
                .padding(-padding)
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
}

/// A vertical stack that adds separators.
/// From https://movingparts.io/variadic-views-in-swiftui
public struct SettingDividedVStack<Content>: View where Content: View {
    public var leadingMargin = CGFloat(0)
    public var trailingMargin = CGFloat(0)
    public var dividerColor: Color?
    @ViewBuilder public var content: Content

    public init(
        leadingMargin: CGFloat = CGFloat(0),
        trailingMargin: CGFloat = CGFloat(0),
        dividerColor: Color? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.leadingMargin = leadingMargin
        self.trailingMargin = trailingMargin
        self.dividerColor = dividerColor
        self.content = content()
    }

    public var body: some View {
        _VariadicView.Tree(
            SettingDividedVStackLayout(
                leadingMargin: leadingMargin,
                trailingMargin: trailingMargin,
                dividerColor: dividerColor
            )
        ) {
            content
        }
    }
}

struct SettingDividedVStackLayout: _VariadicView_UnaryViewRoot {
    var leadingMargin: CGFloat
    var trailingMargin: CGFloat
    var dividerColor: Color?

    @ViewBuilder func body(children: _VariadicView.Children) -> some View {
        let last = children.last?.id

        VStack(spacing: 0) {
            ForEach(children) { child in
                child

                if child.id != last {
                    Divider()
                        .opacity(dividerColor == nil ? 1 : 0)
                        .overlay {
                            if let dividerColor {
                                dividerColor
                            }
                        }
                        .padding(.leading, leadingMargin)
                        .padding(.trailing, trailingMargin)
                }
            }
        }
    }
}
