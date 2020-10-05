//
//  ChromeView.swift
//  Glyph
//
//  Created by Sky Morey on 8/29/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import SwiftUI

class ChromeStateModel: ObservableObject {
    @Published var title: String = "Start"
}

struct ChromeView: View {
    var model: ChromeStateModel
    
    @State var flash = false
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                // Avatar
                VStack {
                    Button(action: { print("person.crop.circle") }) {
                        Image(systemName: "person.crop.circle")
                            .font(Font.system(.largeTitle))
                    }
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
                
                // Message
                VStack {
                    Text(self.model.title)
                        .font(Font.system(.title))
                        .frame(width: geometry.size.width / 2)
                        .foregroundColor(.blue)
                        .background(Color.gray)
                        .opacity(0.5)
                    
                    Spacer()
                }
                
                Spacer()
                
                // Camera Actions
                VStack {
                    Button(action: { print("camera.rotate") }) {
                        Image(systemName: "camera.rotate")
                            .font(Font.system(.largeTitle))
                    }
                    .padding()
                    
                    Button(action: {
                        self.flash.toggle()
                        AppServices.toggleFlash()
                        
                    }) {
                        Image(systemName: self.flash ? "bolt.fill" : "bolt")
                            .font(Font.system(.largeTitle))
                    }
                    .padding()
                    
                    Spacer()
                }
            }
        }
    }
}

struct ChromeView_Previews: PreviewProvider {
    static var previews: some View {
        ChromeView(model: ChromeStateModel())
    }
}
