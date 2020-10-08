//
//  UIView2.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import SwiftUI
//import SwiftUIJson

struct UIView2: View {
    let info: UIInfo
    
    init(info: UIInfo) {
        self.info = info
    }
    
    var body: some View {
        get { return Text("HERE") }
    }
}

struct UIView2_Previews: PreviewProvider {
    static var previews: some View {
        UIView2(info: UIInfo())
    }
}
