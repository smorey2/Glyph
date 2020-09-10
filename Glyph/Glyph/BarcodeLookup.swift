//
//  BarcodeDetector.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import Foundation
import SwiftUI

enum BarcodeType {
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

class BarcodeLookup {
    
    // Shared session
    let session: URLSession = URLSession.shared
    
    public func lookup(with url: URL, completionHandler handler: @escaping (BarcodeType, Any) -> Void) {
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

enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}

struct ImageInfo {
    let url:String
    
    init() {
       url = "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png"
    }
    init(json: [String: Any]) throws {
        guard let url = json["url"] as? String else {
            throw SerializationError.missing("url")
        }
        self.url = url
    }
}

struct AVPlayerInfo {
    let url:String
    let loop:Bool
    
    init() {
        url = "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4"
        loop = false
    }
    init(json: [String: Any]) throws {
        guard let url = json["url"] as? String else {
            throw SerializationError.missing("url")
        }
        let loop = json["loop"] as? Bool ?? false
        self.url = url
        self.loop = loop
    }
}

struct UIInfo {
    let body: Any
    
    init() {
        body = VStack {
            Text("NONE")
        }
    }
    init(json: [String: Any]) throws {
        body = VStack {
            Text("NONE")
        }
    }
}

struct WebInfo {
    let url:String
    
    init() {
        url = "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png"
    }
    init(json: [String: Any]) throws {
        guard let url = json["url"] as? String else {
            throw SerializationError.missing("url")
        }
        self.url = url
    }
}

struct ButtonInfo {
    let text:String
    
    init() {
        text = "Tap Me"
    }
    init(json: [String: Any]) throws {
        guard let text = json["text"] as? String else {
            throw SerializationError.missing("text")
        }
        self.text = text
    }
}
