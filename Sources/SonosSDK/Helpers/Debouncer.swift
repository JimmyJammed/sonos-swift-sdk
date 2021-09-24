//
//  File.swift
//  
//
//  Created by James Hickman on 2/20/21.
//

import Foundation

public class Debouncer {
    
    private let timeInterval: TimeInterval
    private var timer: Timer?
    
    public typealias Handler = () -> Void
    public var handler: Handler?
    
    public init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    public func renewInterval() {
        DispatchQueue.main.async {
            self.timer?.invalidate()
            self.timer = nil
            self.timer = Timer.scheduledTimer(withTimeInterval: self.timeInterval, repeats: false, block: { [weak self] (timer) in
                self?.timeIntervalDidFinish(for: timer)
            })
        }
    }
    
    @objc private func timeIntervalDidFinish(for timer: Timer) {
        guard timer.isValid else {
            return
        }
        
        handler?()
        handler = nil
    }
    
}
