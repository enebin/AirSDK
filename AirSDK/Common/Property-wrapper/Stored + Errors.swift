//
//  Stored + Errors.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/06/09.
//

import Foundation

extension Stored {
    enum StorageError: LocalizedError {
        case emptyValue
        
        var errorDescription: String? {
            switch self {
            case .emptyValue:
                return "Stored value cannot be a nil"
            }
        }
    }
}
