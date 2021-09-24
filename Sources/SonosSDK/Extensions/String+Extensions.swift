//
//  File.swift
//  
//
//  Created by James Hickman on 2/5/21.
//

import Foundation

extension String {
    
    var base64encoded: String? {
        let utf8str = data(using: .utf8)
        return utf8str?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
    }

    func base64decoded() -> String? {
        guard let base64Decoded = Data(base64Encoded: self, options: Data.Base64DecodingOptions(rawValue: 0))
                .map({ String(data: $0, encoding: .utf8) }) else { return nil }
        return base64Decoded
    }

}
