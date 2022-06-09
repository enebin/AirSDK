//
//  Stored.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/06/09.
//

import Foundation

@propertyWrapper
struct Stored<T: Codable> {
    private let fileManager: FileManager
    private let path: URL
    private var value: T? = nil
    
    /// A bool value indicating the value was saved before
    private(set) var projectedValue: Bool = false
    
    var wrappedValue: T {
        get {
            if let value = self.value {
                return value
            } else {
                do {
                    let data = try Data(contentsOf: path)
                    let object = try self.convertToObject(from: data)
                    return object
                }
                catch let error {
                    fatalError(error.localizedDescription)
                }
            }
        }
        set {
            do {
                let data = try convertToData(from: newValue)
                try data.write(to: path)
                
                self.value = newValue
                self.projectedValue = true
            }
            catch let error {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Inits
    init(_ path: String,
         _ fileManager: FileManager = FileManager.default) {
        self.fileManager = fileManager
        
        let home = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.path = home.appendingPathComponent(path, isDirectory: true)
        
        // Init with the stored value
        if fileManager.fileExists(atPath: self.path.absoluteString) {
            self.value = self.wrappedValue
        } else {
            fatalError("Stored value hasn't been configured before.")
        }
    }
    
    init(wrappedValue: T,
         _ path: String,
         _ fileManager: FileManager = FileManager.default
    ) {
        self.fileManager = fileManager
        
        let home = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.path = home.appendingPathComponent(path, isDirectory: true)
        
        // Init with the given parameter
        self.value = wrappedValue
    }
}

extension Stored {
    // MARK: - Internal methods
    private func convertToData(from object: T?) throws -> Data {
        let encoder = JSONEncoder()
        let encoded = try encoder.encode(object)
        
        return encoded
    }
    
    private func convertToObject(from data: Data) throws -> T {
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(T.self, from: data)
        
        return decoded
    }
}
