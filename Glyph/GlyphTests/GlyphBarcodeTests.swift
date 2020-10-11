//
//  GlyphTests.swift
//  GlyphTests
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import XCTest
@testable import Glyph

class GlyphBarcodeTests: XCTestCase {
    var initValues:[String:(
        size:GlyphSize,
        url:URL?,
        multi:Bool,
        body:String?)] = ["""
size: 1x1
url: https://url.com
multi

body
""": (GlyphSize(string: "1x1")!, URL(string: "https://url.com"), true, "body"), """
size: 2x2
https://url.com
""": (GlyphSize(string: "2x2")!, URL(string: "https://url.com"), false, nil), """
size: 3x3
        
https://url.com
""": (GlyphSize(string: "3x3")!, URL(string: "https://url.com"), false, nil)]
    
    func test_parse_initValues() {
        for (value, expected) in initValues {
            let actual = GlyphBarcode(string: value, refresh: {})
            XCTAssert(
                actual.sizes[expected.size.selector] == expected.size && actual.url == expected.url && actual.multi == expected.multi && actual.body == expected.body,
                "\(value)")
        }
    }
    
}
