//
//  File.swift
//  
//
//  Created by James Hickman on 2/7/21.
//

import Foundation
import SwiftyJSON

public struct Household: Identifiable {
    
    public var id: String
    public var name: String?

    init?(_ data: Any) {
        
        let json = JSON(data)
        guard let id = json["id"].string else { return nil }
        
        self.id = id
        self.name = json["name"].string
    }

}
