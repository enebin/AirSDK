//
//  ThreadSafeArray.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/30.
//

import Foundation

class ThreadSafeArray<T> {
    private lazy var semaphore = DispatchSemaphore(value: 1)
    private var array: [T]
    
    init (array: [T]) {
        self.array = array
    }
    
    subscript(index: Int) -> T {
        get {
            self.waitAndSignal()
            return array[index]
        }
        set(newValue) {
            self.waitAndSignal()
            array[index] = newValue
        }
    }
    
    func append(_ newElement: T) {
        self.waitAndSignal()
        array.append(newElement)
    }
    
    var first: T? {
        self.waitAndSignal()
        return array.first
    }
    
    var count: Int {
        self.waitAndSignal()
        return array.count
    }
    
    func forEach(_ closure: (T) -> Void) {
        self.waitAndSignal()
        self.array.forEach { T in
            closure(T)
        }
    }
    
    func removeAll() {
        self.array.removeAll()
    }
        
    private func waitAndSignal() {
        defer {
            semaphore.signal()
        }
        semaphore.wait()
    }
}
