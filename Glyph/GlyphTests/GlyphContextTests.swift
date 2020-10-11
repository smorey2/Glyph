//
//  GlyphTests.swift
//  GlyphTests
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import XCTest
@testable import Glyph

class GlyphContextTests: XCTestCase {
    func testInit() {
        let context = GlyphContext("""
size: 10x10
tag:
url:
multi

https://url.com
""")
        XCTAssert(context.body == "https://url.com")
    }
    
    func testInit2() {
        let context = GlyphContext(
"""
size: 10x10
https://url.com
""")
        XCTAssert(context.body == "https://url.com")
    }
}
