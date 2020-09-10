//
//  SampleView.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import SwiftUI

struct ButtonView: View {
    let info: ButtonInfo
    
    init(info: ButtonInfo) {
        self.info = info
    }
    
    var body: some View {
        Button(action: {
            
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                //.frame(width: 150, height: 50)
                Text(self.info.text)
            }
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView(info: ButtonInfo())
    }
}
