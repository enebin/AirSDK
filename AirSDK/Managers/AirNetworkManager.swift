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
    
    /// Sending an event to the server, handle the results of a network request
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
    
    /// Request conversion of an universal link from the server to a scheme link
    func convertDeeplink(_ host: String, _ queryItems: [URLQueryItem]) {
        self.requestConvertedLink(host, queryItems) { result in
            // TODO: Error handle
            NSLog("AirSDK - \(result)")
        }
    }
    
    /// Sends a network request to report the event
    ///
    /// You can use it whenever need to transmit the events to and sometimes receive responses from the server.
    ///
    /// - Parameters:
    ///      - event:AirTrackableEvent you want to hand in
    ///      - completion: Completion closure which returns error when it occurs
    private func sender(for event: AirTrackableEvent,
                        completion: @escaping (Result<Data, Error>) -> Void) {
        do {
            let request = try self.convertEventToRequest(from: event)
            
            URLSession.shared.dataTask(with: request) { data, response, _ in
                let result = self.commonResponseHandler(data, response)
                completion(result)
            }
            .resume()
        } catch(let error) {
            completion(.failure(error))
        }
    }
    
    /// Sends a network request for conversion
    private func requestConvertedLink(_ host: String, _ queryItems: [URLQueryItem],
                                       completion: @escaping (Result<DeeplinkResponse, Error>) -> Void) {
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
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            let result = self.commonResponseHandler(data, response)
            
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let data):
                guard let decoded = try? JSONDecoder().decode(DeeplinkResponse.self, from: data) else {
                    completion(.failure(AirNetworkError.unableToDecode))
                    return
                }
                completion(.success(decoded))
            }
        }
        .resume()
    }
    
    /// Handle possible errors while communicating with the server
    ///
    /// - Returns: `Result` type variable containing an error
    private func commonResponseHandler(_ data: Data?, _ response: URLResponse?) -> Result<Data, Error> {
        guard let data = data else {
            return .failure(AirNetworkError.unableToGetData)
        }
        
        if let response = response as? HTTPURLResponse {
            switch response.statusCode {
            case 200..<300:
                return .success(data)
            case 400..<500:
                return .failure(AirNetworkError.badRequest)
            case 500..<600:
                return .failure(AirNetworkError.internalServerError)
            default:
                return .failure(AirNetworkError.unknown)
            }
        } else {
            return .failure(AirNetworkError.unableToGetResponse)
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
