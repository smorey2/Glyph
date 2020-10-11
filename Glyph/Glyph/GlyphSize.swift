//
//  GlyphSize.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import Foundation

public struct GlyphSize: Equatable, CustomStringConvertible, Codable {
    public enum Selector {
        case fixed, normal, focus, active
        public var description: String {
            switch self {
            case .fixed: return ":fixed"
            case .normal: return ":normal"
            case .focus: return ":focus"
            case .active: return ":active"
            }
        }
        init(value: String) {
            switch value.lowercased() {
            case ":fixed": self = .fixed
            case ":normal": self = .normal
            case ":focus": self = .focus
            case ":active": self = .active
            default: self = .normal
            }
        }
    }
    public enum WidthAnchor: CustomStringConvertible {
        case left, center, right
        public var description: String {
            switch self {
            case .left: return "l"
            case .center: return "c"
            case .right: return "r"
            }
        }
        public init(value: String) {
            switch value.lowercased() {
            case "l", "t": self = .left
            case "c": self = .center
            case "r", "b": self = .right
            default: self = .center
            }
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
        public init(value: String) {
            switch value.lowercased() {
            case "t", "l": self = .top
            case "c": self = .center
            case "b", "r": self = .bottom
            default: self = .center
            }
        }
    }
    
    public static let empty: GlyphSize = GlyphSize("")!
    public let selector: Selector
    public let widthMultiple: Bool
    public let width: Double
    public let widthAnchor: WidthAnchor
    public let widthOffset: Double
    public let heightMultiple: Bool
    public let height: Double
    public let heightAnchor: HeightAnchor
    public let heightOffset: Double
    
    public var description: String {
        var b = [String]()
        if widthMultiple { b.append("*") }
        b.append(String(width))
        if widthAnchor != .center || widthOffset != 0  { b.append(widthAnchor.description) }
        if widthOffset != 0 { b.append(String(widthOffset))}
        b.append("x")
        if heightMultiple { b.append("*") }
        b.append(String(height))
        if heightAnchor != .center || heightOffset != 0  { b.append(heightAnchor.description) }
        if heightOffset != 0 { b.append(String(heightOffset))}
        if selector != .normal { b.append(selector.description)}
        return b.joined()
    }
    
    public init?(_ value: String) {
        if value == "" {
            selector = .normal
            widthMultiple = true
            width = 1
            widthAnchor = .center
            widthOffset = 0
            heightMultiple = true
            height = 1
            heightAnchor = .center
            heightOffset = 0
            return
        }
        else if value == "~" {
            self = Self.empty
            return
        }
        
        // lines
        let lines = value.components(separatedBy: ["x", "X"])
        let wvalue = lines[0], hvalue = lines[lines.count > 1 ? 1 : 0]
        var idx: String.Index, endIdx: String.Index, nextIdx: String.Index?, nextValue: Substring
        
        // selector
        self.selector = .normal
        
        // width
        idx = wvalue.startIndex
        endIdx = wvalue.endIndex
        self.widthMultiple = wvalue.starts(with: "*")
        if self.widthMultiple { idx = wvalue.index(after: idx) }
        nextIdx = wvalue[idx..<endIdx].firstIndex { $0 < "+" || $0 > "9" }
        nextValue = wvalue[idx..<(nextIdx ?? endIdx)]
        guard let width = Double(nextValue) else { return nil }
        self.width = width
        if nextIdx != nil {
            self.widthAnchor = WidthAnchor(value: String(wvalue[nextIdx!]))
            idx = wvalue.index(after: nextIdx!)
            nextIdx = wvalue[idx..<endIdx].firstIndex { $0 < "+" || $0 > "9" }
            nextValue = wvalue[idx..<(nextIdx ?? endIdx)]
            if nextValue.count > 0 {
                guard let widthOffset = Double(nextValue) else { return nil }
                self.widthOffset = widthOffset
            }
            else {
                self.widthOffset = 0
            }
        }
        else {
            self.widthAnchor = .center
            self.widthOffset = 0
        }
        
        // height
        idx = hvalue.startIndex
        endIdx = hvalue.endIndex
        self.heightMultiple = hvalue.starts(with: "*")
        if self.heightMultiple { idx = hvalue.index(after: idx) }
        nextIdx = hvalue[idx..<endIdx].firstIndex { $0 < "+" || $0 > "9" }
        nextValue = hvalue[idx..<(nextIdx ?? endIdx)]
        guard let height = Double(nextValue) else { return nil }
        self.height = height
        if nextIdx != nil {
            self.heightAnchor = HeightAnchor(value: String(hvalue[nextIdx!]))
            idx = wvalue.index(after: nextIdx!)
            nextIdx = hvalue[idx..<endIdx].firstIndex { $0 < "+" || $0 > "9" }
            nextValue = hvalue[idx..<(nextIdx ?? endIdx)]
            if nextValue.count > 0 {
                guard let heightOffset = Double(nextValue) else { return nil }
                self.heightOffset = heightOffset
            }
            else {
                self.heightOffset = 0
            }
        }
        else {
            self.heightAnchor = .center
            self.heightOffset = 0
        }
    }
    
    public static func == (a: GlyphSize, b: GlyphSize) -> Bool {
        a.selector == b.selector &&
            a.widthMultiple == b.widthMultiple &&
            a.width == b.width &&
            a.widthAnchor == b.widthAnchor &&
            a.widthOffset == b.widthOffset &&
            a.heightMultiple == b.heightMultiple &&
            a.height == b.height &&
            a.heightAnchor == b.heightAnchor &&
            a.heightOffset == b.heightOffset
    }
    
    // MARK - Codable
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(String.self))!
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }
}
