//
//  AVPlayerView.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

struct AVPlayerInfo {
    let url:String
    let loop:Bool
    
    init() {
        url = "https://www.learningcontainer.com/wp-content/uploads/2020/05/sample-mp4-file.mp4"
        loop = false
    }
    init(json: [String: Any]) throws {
        guard let url = json["url"] as? String else {
            throw GlyphLookupError.missing("url")
        }
        let loop = json["loop"] as? Bool ?? false
        self.url = url
        self.loop = loop
    }
}
