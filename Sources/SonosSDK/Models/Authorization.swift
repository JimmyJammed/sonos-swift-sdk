//
//  File.swift
//  
//
//  Created by James Hickman on 2/7/21.
//

import Foundation

struct Authorization: Codable {
    
    var state: String
    var code: String

    init?(fromURL url: URL) {
        guard let state = url["state"], // TODO: Verify state response matches request
              let code = url["code"] else { return nil }
        print("Code: \(code)")
        self.state = state
        self.code = code
    }

}
