//
//  AirDeeplink.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/10.
//

import Foundation

/// Manage actions related to Deeplink
class AirDeeplinkManager {
    static let shared = AirDeeplinkManager()
    
    // MARK: - Public methods
    
    /// Handle the events that triggered by deeplink
    ///
    /// - Parameters
    ///     - url: Deeplink url
    ///     - completion: Completion closure for `Result` variable containing URL or an error
    func handleDeeplink(_ url: URL, completion: @escaping (Result<URL, NetworkError>) -> Void) {
        do {
            // FIXME: Should consider position according to policies
            EventNotificationCenter.default.post(name: EventNotification.deeplink.name, object: nil)
            
            let type = try self.getLinkType(url)
            switch type {
            case .scheme:
                try handleSchemeLinkEvent(url)
                completion(.success(url))
            case .universal:
                try handleUniversalLinkEvent(url) { result in
                    switch result {
                    case .success(let url):
                        completion(.success(url))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        } catch let error as NetworkError {
            completion(.failure(error))
        } catch let error {
            completion(.failure(.unknown(error: error)))
        }
    }
    
    /// Handle the event received with `scheme link`
    func handleSchemeLinkEvent(_ url: URL) throws {
        guard let host = url.host else {
            throw NetworkError.invalidUrl
        }
        
        AirLoggingManager.logger(message: "Deeplink(scheme) is activated(url: \"\(host)\(url.path)\")", domain: "Deeplink.handleSchemeLinkEvent")
    }
    
    /// Handle the event received with `universal link`
    func handleUniversalLinkEvent(_ url: URL, completion: @escaping (Result<URL, NetworkError>) -> Void) throws {
        guard let parsedUrl = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw AirDeeplinkError.invalidUrl
        }
        
        guard let host = parsedUrl.host else {
            throw AirDeeplinkError.invalidHost
        }
        
        guard let queryItems = parsedUrl.queryItems else {
            throw AirDeeplinkError.invalidQueryItems
        }
        
        AirAPIManager.shared.convertDeeplink(host, queryItems) { result in
            switch result {
            case .failure(let error):
                completion(.failure(.unknown(error: error)))
            case .success(let response):
                guard let url = URL(string: response.deeplink) else {
                    completion(.failure(.invalidUrl))
                    return
                }
                
                completion(.success(url))
            }
        }
        
        guard let host = url.host else {
            throw NetworkError.invalidUrl
        }
        
        AirLoggingManager.logger(message: "Deeplink(universal link) is activated(url: \"\(host)\(url.path)\")", domain: "Deeplink.handleUniversalLinkEvent")
    }
    
    // MARK: - Internal methods
    
    private func getLinkType(_ url: URL) throws -> LinkType {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw AirDeeplinkError.invalidUrl
        }
        
        if components.scheme == "http" || components.scheme == "https" {
            return .universal
        } else {
            return .scheme
        }
    }
}

extension AirDeeplinkManager {
    enum LinkType {
        case scheme
        case universal
    }
}
