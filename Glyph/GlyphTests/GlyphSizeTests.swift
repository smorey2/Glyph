//
//  GlyphTests.swift
//  GlyphTests
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import XCTest
@testable import Glyph

class GlyphSizeTests: XCTestCase {
    var initValues:[String:(
        widthMultiple:Bool, width:Double, widthAnchor:GlyphSize.WidthAnchor, widthOffset:Double,
        heightMultiple:Bool, height:Double, heightAnchor:GlyphSize.HeightAnchor, heightOffset:Double)] = [
            "~":            (true, 1, .center, 0, true, 1, .center, 0),
            "1":            (false, 1, .center, 0, false, 1, .center, 0),
//            "1:blur":       (false, 1, .center, 0, false, 1, .center, 0),
            "1c1":          (false, 1, .center, 1, false, 1, .center, 1),
            "*1r":          (true, 1, .right, 0, true, 1, .bottom, 0),
            "1x2":          (false, 1, .center, 0, false, 2, .center, 0),
            "1l1x2c2":      (false, 1, .left, 1, false, 2, .center, 2),
            "1c-1x2":       (false, 1, .center, -1, false, 2, .center, 0),
            "*1r+1x2":      (true, 1, .right, 1, false, 2, .center, 0),
            "+1.5c2.3x2":   (false, 1.5, .center, 2.3, false, 2, .center, 0),
            "*+1.23x*-2.23":(true, 1.23, .center, 0, true, -2.23, .center, 0),
            "*-1.2l-5.6x*+2.3b+5.3":(true, -1.2, .left, -5.6, true, 2.3, .bottom, 5.3)
        ]
    
    func test_parse_initValues() {
        for (value, expected) in initValues {
            if let actual = GlyphSize(value) { XCTAssert(
                actual.widthMultiple == expected.widthMultiple &&
                    actual.width == expected.width &&
                    actual.widthAnchor == expected.widthAnchor &&
                    actual.widthOffset == expected.widthOffset &&
                    actual.heightMultiple == expected.heightMultiple &&
                    actual.height == expected.height &&
                    actual.heightAnchor == expected.heightAnchor &&
                    actual.heightOffset == expected.heightOffset,
                "\(value)"
            )}
            else { XCTAssert(false, "\(value)!") }
        }
    }
}
