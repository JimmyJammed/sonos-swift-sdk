//
//  File.swift
//  
//
//  Created by James Hickman on 2/22/21.
//

import Foundation
import SwiftyJSON

public struct HomeTheaterOptions {
    
    public var nightMode: Bool = false
    public var enhanceDialog: Bool = false

    public init() { }

    init?(_ data: Any) {
        
        let json = JSON(data)
        guard let nightMode = json["nightMode"].bool,
              let enhanceDialog = json["enhanceDialog"].bool else { return nil }
        
        self.nightMode = nightMode
        self.enhanceDialog = enhanceDialog
    }

}
