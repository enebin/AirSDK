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
    
    // MARK: - Public methods
    
    /// Sending an event to the server, handle the results of a network request
    func sendEventToServer(event: AirTrackableEvent) {
        self.sender(for: event) { result in
            switch result {
            case .success:
                AirLoggingManager.logger(message: event.message, domain: "AirSDK")
            case .failure(let error):
                // Handles or throws an error in here
                AirLoggingManager.logger(message: error.localizedDescription, domain: "Error")
            }
        }
    }
    
    /// Request conversion of an universal link from the server to a scheme link
    func convertDeeplink(_ host: String, _ queryItems: [URLQueryItem],
                         completion: @escaping (Result<DeeplinkResponse, Error>) -> Void) {
        self.requestConvertedLink(host, queryItems) { result in
            // TODO: Error handle
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                completion(.success(response))
            }
        }
    }
    
    // MARK: - Internal methods
    
    /// Sends a network request to report the event
    ///
    /// You can use it whenever need to transmit the events to
    /// and sometimes receive responses from the server.
    ///
    /// - Parameters:
    ///      - event:AirTrackableEvent you want to hand in
    ///      - completion: Completion closure which returns error when it occurs
    private func sender(for event: AirTrackableEvent,
                        completion: @escaping (Result<Data, NetworkError>) -> Void) {
        do {
            let request = try self.convertEventToRequest(from: event)
            
            guard let task = NetworkDownloader<Data>.request(with: request, completion: { result in
                switch result {
                case .failure(let error):
                    completion(.failure(error))
                case .success(let data):
                    completion(.success(data))
                }
            }) else {
                throw NetworkError.invalidUrl
            }
            
            task.resume()
        } catch let error as NetworkError {
            completion(.failure(error))
        } catch let error {
            completion(.failure(.unknown(error: error)))
        }
    }
    
    /// Sends a network request for conversion
    private func requestConvertedLink(_ host: String,
                                      _ queryItems: [URLQueryItem],
                                       completion: @escaping (Result<DeeplinkResponse, NetworkError>) -> Void) {
        var newlyAddedItems = queryItems
        newlyAddedItems.append(URLQueryItem(name: "ad_type", value: "server_to_server_click"))
        newlyAddedItems.append(URLQueryItem(name: "no_event_processing", value: "1"))

        var newUrl = URLComponents(string: "https://\(host)")!
        newUrl.queryItems = newlyAddedItems
        
        var request = URLRequest(url: newUrl.url!)
        request.addValue("User-Agent",
                         forHTTPHeaderField:
                            "Airbridge_{\"iOS\"}_SDK/{sdk version} (iOS {os version}; Apple {device identier}; locale {local}; timezone {timezone}; width {width}; height {height}; {bundle identifier}/{app version})"
        )
        
        let task = NetworkDownloader<DeeplinkResponse>.request(with: request) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let decoded):
                completion(.success(decoded))
            }
        }
        
        guard let task = task else {
            completion(.failure(.invalidUrl))
            return
        }
        
        task.resume()
    }
    
    /// Convert `AirTrackableEvent` to a `URLRequest`
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
            throw NetworkError.invalidEvent
        }
    }
}
