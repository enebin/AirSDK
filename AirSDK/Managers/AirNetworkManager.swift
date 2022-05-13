//
//  AirNetworkManager.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/10.
//

import Foundation

/// Provide methods related to handling network request
///
/// Each method guarantees the success of the request
class AirNetworkManager {
    static let shared = AirNetworkManager()
    
    /// Handle the results of a network request
    func sendEventToServer(event: AirTrackableEvent) {
        self.sender(for: event) { result in
            switch result {
            case .success:
                AirLoggingManager.logger(message: event.message, domain: "AirSDK")
            case .failure(let error):
                // Handle errors in here
                AirLoggingManager.logger(message: error.localizedDescription, domain: "Error")
            }
        }
    }
    
    /// Sends a network request
    ///
    /// You can use it whenever need to transmit the events to and sometimes receive responses from the server.
    ///
    /// - Parameters:
    ///      - event:AirTrackableEvent you want to hand in
    ///      - completion: Completion closure which returns error when it occurs
    private func sender(for event: AirTrackableEvent,
                        completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            let request = try self.convertEventToRequest(from: event)
            URLSession.shared.dataTask(with: request) { data, response, _ in
                if let response = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200..<300:
                        completion(.success(()))
                    case 400..<500:
                        completion(.failure(AirNetworkError.badRequest))
                    case 500..<600:
                        completion(.failure(AirNetworkError.internalServerError))
                    default:
                        completion(.failure(AirNetworkError.unknown))
                    }
                }
            }
            .resume()
            
        } catch(let error) {
            completion(.failure(error))
        }
    }
    
    /// Convert `AIrTrackableEvent` to a `URLRequest`
    ///
    /// Sample descriptions
    ///
    /// - Parameters:
    ///     - event: AirTrackableEvent you want to convert
    ///
    /// - Returns: Converted `URLRequest` used to make a network request
    ///
    /// - Throws: `AirError.invalidEvent` if the event isn't a type of `AirTrackableEvent`
    private func convertEventToRequest(from event: AirTrackableEvent) throws -> URLRequest {
        // FIXME: Add extra codes here
        
        
        
        // FIXME: Temporary URL address
        if let request = URL(string: "https://www.naver.com") {
            return URLRequest(url: request)
        } else {
            throw AirNetworkError.invalidEvent
        }
    }
}
