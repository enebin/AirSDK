//
//  NetworkManager.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/18.
//

import Foundation

/// Handle download task between network and SDK
final class NetworkDownloader<T: Decodable> {
    typealias Completion<T: Decodable> = (Result<T, NetworkError>) -> Void
    
    // MARK: - Public methods
    
    /// Factory making an `URLSessionDataTask` from the `URL`
    ///
    /// - `GET` method by default
    /// - Don't forget to `resume` the returned `URLSessionDataTask`
    ///
    /// - Returns: `URLSessionDataTask`
    @discardableResult
    static func request(with url: String, completion: @escaping Completion<T>) -> URLSessionDataTask? {
        guard let url = URL(string: url) else {
            completion(.failure(.invalidUrl))
            return nil
        }
        
        let task = URLSession.shared.dataTask(with: url) {  data, response, error in
            self.responseHandler(data, response, error, completion)
        }
        
        return task
    }
    
    /// Factory making an `URLSessionDataTask` from the `URLRequest`
    ///
    /// - You don't have to pass an `URL` but an`URLRequest`
    /// - `GET` method by default
    /// - Don't forget to `resume` the returned `URLSessionDataTask`
    ///
    /// - Returns: `URLSessionDataTask`
    @discardableResult
    static func request(with request: URLRequest, completion: @escaping Completion<T>) -> URLSessionDataTask? {
        let task = URLSession.shared.dataTask(with: request) {  data, response, error in
            self.responseHandler(data, response, error, completion)
        }
        
        return task
    }
    
    // MARK: - Internal methods
    
    /// Handling received response from the network request
    ///
    /// Submits its result by a completion
    static private func responseHandler(_ data: Data?, _ response: URLResponse?, _ error: Error?, _ completion: Completion<T>) {
        
        if let error = error {
            completion(.failure(.unknown(error: error)))
            return
        }
        
        guard let data = data else {
            completion(.failure(.unableToGetData))
            return
        }
        
        if let response = response as? HTTPURLResponse {
            switch response.statusCode {
            case 200..<300:
                break
            case 400..<500:
                completion(.failure(NetworkError.badRequest))
                return
            case 500..<600:
                completion(.failure(NetworkError.internalServerError))
                return
            default:
                completion(.failure(NetworkError.unableToGetResponse))
                return
            }
        } else {
            return completion(.failure(NetworkError.unableToGetResponse))
        }
        
        do {
            let model = try JSONDecoder().decode(T.self, from: data)
            completion(.success(model))
        }
        catch is DecodingError { // FIXME: Temporary
            completion(.success(data as! T))
        }
        catch let error {
            completion(.failure(.unableToDecode(error: error)))
        }
    }
}
