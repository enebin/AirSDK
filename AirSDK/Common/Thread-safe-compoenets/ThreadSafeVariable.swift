//
//  ThreadSafeArray.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/30.
//

import Foundation

class ThreadSafeVariable<T> {
    private lazy var semaphore = DispatchSemaphore(value: 1)
    private var element: T?
    
    init (element: T?) {
        self.element = element
    }
    
    func remove() {
        self.element = nil
    }
    
    func set(_ newValue: T) {
        self.waitAndSignal()
        self.element = newValue
    }
    
    func get() -> T? {
        self.waitAndSignal()
        return self.element
    }
        
    private func waitAndSignal() {
        defer {
            semaphore.signal()
        }
        semaphore.wait()
    }
}
