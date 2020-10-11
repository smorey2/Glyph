//
//  SampleView.swift
//  Glyph
//
//  Created by Sky Morey on 8/22/20.
//  Copyright © 2020 Sky Morey. All rights reserved.
//

import SwiftUI
import Combine

struct ImageInfo {
    let url:String
    
    init() {
       url = "https://www.google.com/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png"
    }
    init(json: [String: Any]) throws {
        guard let url = json["url"] as? String else {
            throw GlyphLookupError.missing("url")
        }
        self.url = url
    }
}

class ImageLoader: ObservableObject {
    var didChange = PassthroughSubject<Data, Never>()
    var data = Data() {
        didSet {
            didChange.send(data)
        }
    }
    
    init(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.data = data
            }
        }
        task.resume()
    }
}

struct ImageView: View {
    @ObservedObject var imageLoader: ImageLoader
    @State var image: UIImage = UIImage()
    
    init(info: ImageInfo) {
        imageLoader = ImageLoader(urlString: info.url)
    }
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .onReceive(imageLoader.didChange) { data in
                self.image = UIImage(data: data) ?? UIImage()
        }
    }
}

struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        ImageView(info: ImageInfo())
    }
}
