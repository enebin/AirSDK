//
//  AirSDK.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/09.
//

import Foundation
import UIKit

/// Main class of the SDK
public class AirSDK {
    // MARK: - Instances
    static var shared: AirSDK?
    static var airEventDecoder: AirEventProcessor?
    static var configuration = AirConfigOptions()

    static let networkManager = AirNetworkManager.shared
    static let deeplinkManager = AirDeeplinkManager.shared
    static let sessionManager = AirSessionManager.shared
    
    // MARK: - Public methods
    
    /// Initializes AirSDK
    ///
    /// Configures a default AirSDK instance.
    /// Raises an error if any configuration step fails.
    ///
    /// - Warning: This method **should be called from the main thread**.
    public static func configure() {
        do {
            try self.initialize()
        } catch let error {
            // FIXME: Handle errors in here
            AirLoggingManager.logger(error: error)
        }
    }
    
    /// Initializes AirSDK with options
    ///
    /// Configures an AirSDK instance with user customized options.
    /// Raises an error if any configuration step fails.
    ///
    /// - Parameters:
    ///     - AirConfigOptions : Struct containing options for operating SDK
    ///
    /// - Warning: This method **should be called from the main thread**.
    public static func configure(_ options: AirConfigOptions) {
        do {
            try self.initializeWithOptions(options)
        } catch let error {
            // FIXME: Handle errors in here
            AirLoggingManager.logger(error: error)
        }
    }
    
    /// Sends a user defined event to the server
    ///
    /// Raises an error if any step fails.
    public static func sendCustomEvent(_ event: String) {
        do {
            try checkIfInitialzed(shared)
            networkManager.sendEventToServer(event: .custom(label: event))
        } catch AirConfigError.notInitialized {
            fatalError(AirConfigError.notInitialized.localizedDescription)
        } catch let error {
            AirLoggingManager.logger(error: error)
        }
    }
    
    /// Handle deeplink received
    ///
    /// Commonly usable
    ///
    /// - Parameters:
    ///     - url: Deeplink url
    public static func handleDeepLink(_ url: URL) {
        do {
            try checkIfInitialzed(shared)
            deeplinkManager.handleDeeplink(url) { result in
                switch result {
                case .failure(let error):
                    AirLoggingManager.logger(error: error)
                case .success(_):
                    break
                }
            }
        } catch AirConfigError.notInitialized {
            fatalError(AirConfigError.notInitialized.localizedDescription)
        } catch let error {
            AirLoggingManager.logger(error: error)
        }
    }

    /// Handle deeplink received
    ///
    /// no matter scheme or universal
    ///
    /// - Parameters
    ///     - url: Deeplink url
    ///     - completion: Completion closure for `Result` variable containing URL or an error
    public static func handleDeepLink(_ url: URL, completion: @escaping (URL?) -> Void) {
        do {
            try checkIfInitialzed(shared)
            deeplinkManager.handleDeeplink(url) { result in
                switch result {
                case .failure(let error):
                    AirLoggingManager.logger(error: error)
                    completion(nil)
                case .success(let url):
                    completion(url)
                }
            }
        } catch AirConfigError.notInitialized {
            fatalError(AirConfigError.notInitialized.localizedDescription)
        } catch let error {
            AirLoggingManager.logger(error: error)
            completion(nil)
        }
    }
    
    // MARK: - Internal methods
    /// Checks if SDK has been initialized properly
    ///
    /// - Throws:`AirConfigError.notInitialized` if SDK hasn't been
    ///  configured before.
    static private func checkIfInitialzed(_ instance: AirSDK?) throws {
        if instance == nil {
            throw AirConfigError.notInitialized
        }
    }
    
    /// Wraps Initializing routine of the SDK
    static private func initialize() throws {
        if self.shared != nil {
            throw AirConfigError.alreadyInitialized
        }
        
        self.shared = AirSDK()
        
        self.startTracking()
    }
    
    /// Wraps Initializing routine of the SDK and configure other instances with the given options
    static private func initializeWithOptions(_ options: AirConfigOptions) throws {
        if self.shared != nil {
            throw AirConfigError.alreadyInitialized
        }
        
        self.shared = AirSDK()
        self.sessionManager.configureWithOptions(options) // or injecting an instance directly?
        
        self.startTracking()
    }
    
    /// Start life cycle tracking by making an `AirEventDecoder` instance.
    static private func startTracking() {
        self.airEventDecoder = AirEventProcessor()
        AirLoggingManager.logger(message: "AirSDK is initialized", domain: "AirSDK")
    }
}


