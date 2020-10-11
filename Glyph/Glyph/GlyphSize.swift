//
//  GlyphSize.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import CoreGraphics

public enum GlyphSelector {
    case fixed, normal, focus, active
    public var description: String {
        switch self {
        case .fixed: return ":fixed"
        case .normal: return ":normal"
        case .focus: return ":focus"
        case .active: return ":active"
        }
    }
    public init(string s: String) {
        switch s.lowercased() {
        case ":fixed": self = .fixed
        case ":normal": self = .normal
        case ":focus": self = .focus
        case ":active": self = .active
        default: self = .normal
        }
    }
    fileprivate init?(parse s: String) {
        guard let endIdx = s.lastIndex(of: ":") else { self = .normal; return }
        self = GlyphSelector(string: String(s[endIdx...]))
    }
}

public struct GlyphSize: Equatable, CustomStringConvertible, Codable {
    public enum WidthAnchor: CustomStringConvertible {
        case left, center, right
        
        public var description: String {
            switch self {
            case .left: return "l"
            case .center: return "c"
            case .right: return "r"
            }
        }
        
        public init(string s: String) {
            switch s.lowercased() {
            case "l", "t": self = .left
            case "c": self = .center
            case "r", "b": self = .right
            default: self = .center
            }
        }
    }
    public struct Width: Equatable, CustomStringConvertible {
        public static let zero = Width(multiple: true, value: 1, anchor: .center, offset: 0)
        public let multiple: Bool
        public let value: CGFloat
        public let anchor: WidthAnchor
        public let offset: CGFloat
        
        public var description: String {
            var b = [String]()
            if multiple { b.append("*") }
            b.append(value.cleanDescription)
            if anchor != .center || offset != 0  { b.append(anchor.description) }
            if offset != 0 { b.append(offset.cleanDescription)}
            return b.joined()
        }
        
        public init(multiple: Bool, value: CGFloat, anchor: WidthAnchor, offset: CGFloat) {
            self.multiple = multiple
            self.value = value
            self.anchor = anchor
            self.offset = offset
        }
        public init?(string s: String) {
            var idx = s.startIndex
            let endIdx = s.lastIndex(of: ":") ?? s.endIndex
            self.multiple = s.starts(with: "*")
            if self.multiple { idx = s.index(after: idx) }
            var nextIdx = s[idx..<endIdx].firstIndex { $0 < "+" || $0 > "9" }
            var nextValue = s[idx..<(nextIdx ?? endIdx)]
            guard let value = Double(nextValue) else { return nil }
            self.value = CGFloat(value)
            if nextIdx != nil {
                self.anchor = WidthAnchor(string: String(s[nextIdx!]))
                idx = s.index(after: nextIdx!)
                nextIdx = s[idx..<endIdx].firstIndex { $0 < "+" || $0 > "9" }
                nextValue = s[idx..<(nextIdx ?? endIdx)]
                if nextValue.count > 0 {
                    guard let offset = Double(nextValue) else { return nil }
                    self.offset = CGFloat(offset)
                }
                else { self.offset = 0 }
            }
            else { self.anchor = .center; self.offset = 0 }
        }
        
        public static func == (a: Width, b: Width) -> Bool {
            a.multiple == b.multiple && a.value == b.value && a.anchor == b.anchor && a.offset == b.offset
        }
    }
    public enum HeightAnchor: CustomStringConvertible {
        case top, center, bottom
        
        public var description: String {
            switch self {
            case .top: return "t"
            case .center: return "c"
            case .bottom: return "b"
            }
        }
        
        public init(string s: String) {
            switch s.lowercased() {
            case "t", "l": self = .top
            case "c": self = .center
            case "b", "r": self = .bottom
            default: self = .center
            }
        }
    }
    public struct Height: Equatable, CustomStringConvertible {
        public static let zero = Height(multiple: true, value: 1, anchor: .center, offset: 0)
        public let multiple: Bool
        public let value: CGFloat
        public let anchor: HeightAnchor
        public let offset: CGFloat
        
        public var description: String {
            var b = [String]()
            if multiple { b.append("*") }
            b.append(value.cleanDescription)
            if anchor != .center || offset != 0  { b.append(anchor.description) }
            if offset != 0 { b.append(offset.cleanDescription)}
            return b.joined()
        }
        
        public init(multiple: Bool, value: CGFloat, anchor: HeightAnchor, offset: CGFloat) {
            self.multiple = multiple
            self.value = value
            self.anchor = anchor
            self.offset = offset
        }
        public init?(string s: String) {
            var idx = s.startIndex
            let endIdx = s.lastIndex(of: ":") ?? s.endIndex
            self.multiple = s.starts(with: "*")
            if self.multiple { idx = s.index(after: idx) }
            var nextIdx = s[idx..<endIdx].firstIndex { $0 < "+" || $0 > "9" }
            var nextValue = s[idx..<(nextIdx ?? endIdx)]
            guard let value = Double(nextValue) else { return nil }
            self.value = CGFloat(value)
            if nextIdx != nil {
                self.anchor = HeightAnchor(string: String(s[nextIdx!]))
                idx = s.index(after: nextIdx!)
                nextIdx = s[idx..<endIdx].firstIndex { $0 < "+" || $0 > "9" }
                nextValue = s[idx..<(nextIdx ?? endIdx)]
                if nextValue.count > 0 {
                    guard let offset = Double(nextValue) else { return nil }
                    self.offset = CGFloat(offset)
                }
                else { self.offset = 0 }
            }
            else { self.anchor = .center; self.offset = 0 }
        }
        
        public static func == (a: Height, b: Height) -> Bool {
            a.multiple == b.multiple && a.value == b.value && a.anchor == b.anchor && a.offset == b.offset
        }
    }
    
    public static let zero: GlyphSize = GlyphSize(selector: .normal, width: Width.zero, height: Height.zero)
    public let selector: GlyphSelector
    public let width: Width
    public let height: Height

    public var description: String {
        if self == Self.zero { return "~" }
        var b = [String]()
        b.append(width.description)
        b.append("x")
        b.append(height.description)
        if selector != .normal { b.append(selector.description)}
        return b.joined()
    }
    
    public init(selector: GlyphSelector, width: Width, height: Height) {
        self.selector = selector
        self.width = width
        self.height = height
    }
    public init?(string s: String) {
        if s == "" || s == "~" {
            self = Self.zero
            return
        }
        let lines = s.components(separatedBy: ["x", "X"])
        guard let selector = GlyphSelector(parse: lines.last!), let width = Width(string: lines.first!), let height = Height(string: lines.last!) else { return nil }
        self.selector = selector
        self.width = width
        self.height = height
    }
    
    public static func == (a: GlyphSize, b: GlyphSize) -> Bool {
        a.selector == b.selector && a.width == b.width && a.height == b.height
    }
    
    // MARK - Codable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(string: try container.decode(String.self))!
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
