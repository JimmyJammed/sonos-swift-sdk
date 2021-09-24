//
//  File.swift
//  
//
//  Created by James Hickman on 2/24/21.
//

import Foundation
import SwiftyJSON

public struct Favorite: Identifiable {
    
    public var id: String
    public var name: String
    public var description: String
    public var imageUrl: URL?
    public var imageCompilation: [URL]?
    public var service: Service?
    
    init?(_ data: Any) {
        
        let json = JSON(data)
        guard let id = json["id"].string,
              let name = json["name"].string,
              let description = json["description"].string else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.description = description
        self.imageUrl = json["imageUrl"].url
        
        var urls: [URL] = []
        if let imageCompilationStrings = json["imageCompilation"].array?.map({ $0.stringValue }) {
            for urlString in imageCompilationStrings {
                if let url = URL(string: urlString) {
                    urls.append(url)
                }
            }
            self.imageCompilation = urls
        }
        
    }

}
