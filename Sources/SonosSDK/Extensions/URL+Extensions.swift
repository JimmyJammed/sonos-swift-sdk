//
//  File.swift
//  
//
//  Created by James Hickman on 2/8/21.
//

import Foundation

extension URL {
    
    subscript(queryParam: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value
    }
    
}
