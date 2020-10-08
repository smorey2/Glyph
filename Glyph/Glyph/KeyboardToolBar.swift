//
//  KeyboardToolBar.swift
//  Glyph
//
//  Created by Sky Morey on 8/29/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import SwiftUI

struct KeyboardToolBar: View {
    @State private var name: String = ""
    @State private var phoneNumber: String = ""
    var body: some View {
        
        NavigationView {
            KeyboardView {
                ScrollView {
                    Spacer()
                    Text("Welcome")
                        .font(.largeTitle)
                    VStack {
                        TextField("Name", text: $name)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary, lineWidth: 1)
                            .frame(height: 50))
                            .keyboardType(.namePhonePad)
                        
                        TextField("Phone Number", text: $phoneNumber)
                            .padding()
                            .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary, lineWidth: 1)
                            .frame(height: 50))
                            .keyboardType(.numberPad)
                        
                        Button(action: {
                            
                        }, label: {
                            Text("Continue")
                        })
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.secondary, lineWidth: 1))
                        
                        
                            
                    }.padding()
                }
            } toolBar: {
                HStack {
                    Spacer()
                    Button(action: {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }, label: {
                        Text("Done")
                    })
                }.padding()
            }
            .navigationBarTitle("Sign Up", displayMode: .inline)
        }
    }
}

struct KeyboardToolBar_Previews: PreviewProvider {
    static var previews: some View {
        KeyboardToolBar()
    }
}
