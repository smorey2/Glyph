//
//  GlyphTests.swift
//  GlyphTests
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import XCTest
@testable import Glyph

typealias Width = GlyphSize.Width
typealias Height = GlyphSize.Height

class GlyphSizeTests: XCTestCase {
    var initValues:[String:(
        selector:GlyphSelector,
        width:Width, height:Height,
        description:String)] = [
            "~":            (.normal, Width(multiple: true, value: 1, anchor: .center, offset: 0), Height(multiple: true, value: 1, anchor: .center, offset: 0), "~"),
            "1":            (.normal, Width(multiple: false, value: 1, anchor: .center, offset: 0), Height(multiple: false, value: 1, anchor: .center, offset: 0), "1x1"),
            "1:active":     (.active, Width(multiple: false, value: 1, anchor: .center, offset: 0), Height(multiple: false, value: 1, anchor: .center, offset: 0), "1x1:active"),
            "1c1":          (.normal, Width(multiple: false, value: 1, anchor: .center, offset: 1), Height(multiple: false, value: 1, anchor: .center, offset: 1), "1c1x1c1"),
            "*1r":          (.normal, Width(multiple: true, value: 1, anchor: .right, offset: 0), Height(multiple: true, value: 1, anchor: .bottom, offset: 0), "*1rx*1b"),
            "1x2":          (.normal, Width(multiple: false, value: 1, anchor: .center, offset: 0), Height(multiple: false, value: 2, anchor: .center, offset: 0), "1x2"),
            "1l1x2c2":      (.normal, Width(multiple: false, value: 1, anchor: .left, offset: 1), Height(multiple: false, value: 2, anchor: .center, offset: 2), "1l1x2c2"),
            "1c-1x2":       (.normal, Width(multiple: false, value: 1, anchor: .center, offset: -1), Height(multiple: false, value: 2, anchor: .center, offset: 0), "1c-1x2"),
            "*1r+1x2":      (.normal, Width(multiple: true, value: 1, anchor: .right, offset: 1), Height(multiple: false, value: 2, anchor: .center, offset: 0), "*1r1x2"),
            "+1.5c2.3x2":   (.normal, Width(multiple: false, value: 1.5, anchor: .center, offset: 2.3), Height(multiple: false, value: 2, anchor: .center, offset: 0), "1.5c2.3x2"),
            "*+1.23x*-2.23":(.normal, Width(multiple: true, value: 1.23, anchor: .center, offset: 0), Height(multiple: true, value: -2.23, anchor: .center, offset: 0), "*1.23x*-2.23"),
            "*-1.2l-5.6x*+2.3b+5.3":(.normal, Width(multiple: true, value: -1.2, anchor: .left, offset: -5.6), Height(multiple: true, value: 2.3, anchor: .bottom, offset: 5.3), "*-1.2l-5.6x*2.3b5.3")
        ]
    
    func test_parse_initValues() {
        for (value, expected) in initValues {
            if let actual = GlyphSize(string: value) {
                XCTAssert(
                    actual.width == expected.width && actual.width == expected.width && actual.height == expected.height,
                    "\(value)")
                XCTAssertEqual(actual.description, expected.description)
            }
            else { XCTAssert(false, "\(value)!") }
        }
    }
}
