//
//  SampleView.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import SwiftUI

struct ButtonInfo {
}

struct ButtonView: View {
    init(info:ButtonInfo) {
    }
    
    var body: some View {
        Button(action: {
            
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    //.frame(width: 150, height: 50)
                Text("Tap Me")
            }
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(info: ButtonInfo())
    }
}
