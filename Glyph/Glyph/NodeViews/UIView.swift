//
//  UIView.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import SwiftUI

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

struct UIView: View {
    let info: UIInfo
    
    init(info: UIInfo) {
        self.info = info
    }
    
    var body: some View {
        get { return Text("HERE") }
    }
}

struct UIView_Previews: PreviewProvider {
    static var previews: some View {
        UIView(info: UIInfo())
    }
}
