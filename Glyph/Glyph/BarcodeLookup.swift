//
//  BarcodeDetector.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import Foundation

enum BarcodeType {
    case none
    case image
    case avplayer
    case ui
    case web
    case button
}

class BarcodeLookup {
    
    // Shared session
    let session: URLSession = URLSession.shared
    
    public func lookup(with url: URL, completionHandler handler: @escaping (BarcodeType, Any) -> Void) {
        session.dataTask(with: url, completionHandler: { (data, response, error) in
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                handler(.none, [])
                return
            }
            handler(.ui, json)
        }).resume()
    }
}
