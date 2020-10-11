//
//  GlyphLookup.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import Foundation
import SwiftUI

enum GlyphType {
    case none
    case error
    case unknown
    case image
    case avplayer
    case ui
    case web
    case button
}

// https://www.hackingwithswift.com/books/ios-swiftui/sending-and-receiving-codable-data-with-urlsession-and-swiftui
// https://www.avanderlee.com/swift/json-parsing-decoding/

enum GlyphLookupError: Error {
    case missing(String)
    case invalid(String, Any)
}

class GlyphLookup {
    
    // Shared session
    let session: URLSession = URLSession.shared
    
    public func lookup(with url: URL, completionHandler handler: @escaping (GlyphType, Any) -> Void) {
        session.dataTask(with: url) { data, response, error in
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                handler(.none, [])
                return
            }
            
            guard let entryType = json.keys.first(where: { $0.starts(with: "_") }) else {
                handler(.unknown, [])
                return
            }
            
            do {
                switch entryType.lowercased() {
                case "_image": handler(.image, try ImageInfo(json: json))
                case "_avplayer": handler(.avplayer, try AVPlayerInfo(json: json))
                case "_ui": handler(.ui, try UIInfo(json: json))
                case "_web": handler(.web, try WebInfo(json: json))
                case "_button": handler(.button, try ButtonInfo(json: json))
                default: handler(.unknown, [])
                }
            }
            catch {
                handler(.error, [])
                return
            }

        }.resume()
    }
}









