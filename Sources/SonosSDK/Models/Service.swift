//
//  File.swift
//  
//
//  Created by James Hickman on 2/24/21.
//

import Foundation
import SwiftyJSON

public struct Service: Identifiable {
    
    public var id: String?
    public var name: String
    public var imageUrl: String?
    
    init?(_ data: Any) {
        
        let json = JSON(data)
        guard let name = json["name"].string else { return nil }
        
        self.id = json["id"].string
        self.name = name
        self.imageUrl = json["imageUrl"].string
    }

}
