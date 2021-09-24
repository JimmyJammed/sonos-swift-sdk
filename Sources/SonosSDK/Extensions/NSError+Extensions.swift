//
//  NSError+Extensions.swift
//  SwiftUIExample
//
//  Created by James Hickman on 3/5/21.
//

import Foundation
import SwiftyJSON

extension NSError {
    
    public class func errorWithMessage(message: String) -> NSError {
        return NSError(domain:"com.sonos-swift-sdk", code:500, userInfo:[NSLocalizedDescriptionKey: message])
    }

    public class func errorWithData(data: Data) -> NSError? {
        let json = JSON(data)
        guard let errorCode = json["errorCode"].string,
              let reason = json["reason"].string
        else {
            return nil
        }

        return NSError(domain:"com.sonos-swift-sdk", code:500, userInfo:[NSLocalizedDescriptionKey: "\(errorCode): \(reason)"])
    }

}
