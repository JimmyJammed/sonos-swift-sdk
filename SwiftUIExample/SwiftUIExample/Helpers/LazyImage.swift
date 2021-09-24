//
//  LazyImage.swift
//  SwiftUIExample
//
//  Created by James Hickman on 3/2/21.
//

import SwiftUI
import Alamofire
import AlamofireImage

struct LazyImage: View {
    private enum LoadState {
        case loading, success, failure
    }

    private class Loader: ObservableObject {
        var data = Data()
        var state = LoadState.loading
        var image: AlamofireImage.Image?

        init(url: String) {
            AF.request(url).responseImage { response in
                if case .success(let image) = response.result {
                    self.state = .success
                    self.image = image
                } else {
                    self.state = .failure
                }
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
            }
        }
    }

    @StateObject private var loader: Loader
    var loading: SwiftUI.Image
    var failure: SwiftUI.Image

    var body: some View {
        selectImage()
            .resizable()
    }

    init(url: String, loading: SwiftUI.Image = Image(systemName: "photo"), failure: SwiftUI.Image = Image(systemName: "multiply.circle")) {
        _loader = StateObject(wrappedValue: Loader(url: url))
        self.loading = loading
        self.failure = failure
    }

    private func selectImage() -> SwiftUI.Image {
        switch loader.state {
        case .loading:
            return loading
        case .failure:
            return failure
        default:
            if let image = loader.image {
                return Image(uiImage: image)
            } else {
                return failure
            }
        }
    }
}
