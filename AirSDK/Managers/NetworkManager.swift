//
//  NetworkManager.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/18.
//

import Foundation

final class NetworkManager<T: Decodable> {
    typealias Completion<T: Decodable> = (Result<T, AirNetworkError>) -> Void
    
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
    
    @discardableResult
    static func request(with request: URLRequest, completion: @escaping Completion<T>) -> URLSessionDataTask? {
        let task = URLSession.shared.dataTask(with: request) {  data, response, error in
            self.responseHandler(data, response, error, completion)
        }
        
        return task
    }
    
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
                    completion(.failure(AirNetworkError.badRequest))
                    return
                case 500..<600:
                    completion(.failure(AirNetworkError.internalServerError))
                    return
                default:
                    completion(.failure(AirNetworkError.unableToGetResponse))
                    return
                }
            } else {
                return completion(.failure(AirNetworkError.unableToGetResponse))
            }
            
            do {
                let model = try JSONDecoder().decode(T.self, from: data)
                completion(.success(model))
            }
            catch let error {
                completion(.failure(.unableToDecode(error: error)))
            }
    }
}
