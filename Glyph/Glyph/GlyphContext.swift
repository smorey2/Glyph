//
//  GlyphContext.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import Foundation

public class GlyphContext {
    public static let empty: GlyphContext = GlyphContext("")
    public let headers: [String:String]
    public var sizes: [GlyphSize]
    public let body: String?
    public var url: URL?
    public let multi: Bool
    
    public init(_ value: String) {
        let lines = value.components(separatedBy: "\n")
        var headers = [String:String]()
        var sizes = [GlyphSize]()
        var body: String? = nil
        for idx in 0..<lines.count {
            let line = lines[idx].trimmingCharacters(in: .whitespacesAndNewlines)
            // break
            if idx > 0, line == "" {
                body = lines[lines.index(lines.startIndex, offsetBy: idx)...].joined(separator: "\n")
                break
            }
            // nonvalue
            guard let separatorIndex = line.firstIndex(of: ":") else {
                headers[line.lowercased()] = "1"
                continue
            }
            let headerName = line[...separatorIndex].trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            // http:https:
            if headerName.starts(with: "http") {
                headers["url"] = line
                continue
            }
            let headerValue = line[line.index(after: separatorIndex)...].trimmingCharacters(in: .whitespacesAndNewlines)
            // size:
            if headerName == "size", let size = GlyphSize(headerValue) {
                sizes.append(size)
                continue
            }
            headers[headerName] = headerValue
        }
        self.headers = headers
        self.sizes = sizes
        self.body = body
        self.url = URL(string: headers["url"] ?? "")
        self.multi = headers["multi"] != nil
        fake()
    }
    
    public func add(key: String, value: String) {
        
    }
    
    public func fake() {
        self.url = URL(string: "http://192.168.1.3/Glyph/image.json")
//        self.url = URL(string: "http://192.168.1.3/Glyph/avplayer_3g2.json")
//        self.url = URL(string: "http://192.168.1.3/Glyph/avplayer_3gp.json")
//        self.url = URL(string: "http://192.168.1.3/Glyph/avplayer_avi.json")
//        self.url = URL(string: "http://192.168.1.3/Glyph/avplayer_mov.json")
//        self.url = URL(string: "http://192.168.1.3/Glyph/avplayer_mp4.json")
//        self.url = URL(string: "http://192.168.1.3/Glyph/avplayer_mpg.json")
//        self.url = URL(string: "http://192.168.1.3/Glyph/button.json")
    }
    
    // MARK: - Lookup
    var type: GlyphType = .none
    var data: Any = ""
    
    internal func lookup(type: GlyphType, data: Any) {
        self.type = type
        self.data = data
    }
}
