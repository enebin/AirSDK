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
    static var airEventProcessor: AirEventProcessor?
    static var configuration = AirConfigOptions()

    static let networkManager = AirAPIManager.shared
    static let deeplinkManager = AirDeeplinkManager.shared
    static let sessionManager = AirSessionManager.shared
    
    // MARK: - Public methods
    
    /// Initializes AirSDK
    ///
    /// Configures a default AirSDK instance.
    /// Raises an error if any configuration step fails.
    ///
    /// - Warning: This method **should be called from the main thread**
    public static func configure() {
        do {
            try self.initialize()
            AirLoggingManager.logger(message: "AirSDK is initialized", domain: "AirSDK.configure")
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
    public static func configure(with options: AirConfigOptions) {
        do {
            try self.initializeWithOptions(options)
            self.configuration = options
            AirLoggingManager.logger(message: "AirSDK is initialized", domain: "AirSDK.configure(with options)")
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

    /// Handle received deeplink by passing it as a parameter
    ///
    /// Regardless of scheme or universal link it handle every routines
    /// which should be done before sending it to the server
    ///
    /// - Parameters:
    ///     - url: A Deeplink url
    ///     - completion: A completion closure for `Result` variable containing `URL` or an error
    ///
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
    
    /// Start event tracking manually
    ///
    /// You must have configured when
    ///
    /// - Warning: Make sure you have set auto-start value in `AirConfigOptions` to `false`.
    ///     If not, it's likely that the SDK has already tracked the event much earlier,
    ///     so data may contain unexpected values.
    public static func startTracking() {
        do {
            try self.checkIfInitialzed(shared)
            // For those who forgot disabling the auto-start...
            if self.configuration.autoStartEnabled {
                throw AirConfigError.autoStartIsEnabled
            }
            
            try self.setAndLaunchTrackers()
        }
        catch AirConfigError.notInitialized {
            fatalError(AirConfigError.notInitialized.localizedDescription)
        }
        catch let error {
            AirLoggingManager.logger(error: error)
        }
    }
    
    /// Pending
    ///
    /// You must have configured when
    ///
    /// - Warning: Make sure you have set auto-start value in `AirConfigOptions` to `false`.
    ///     If not, it's likely that the SDK has already tracked the event much earlier,
    ///     so data may contain unexpected values.
    public static func waitingForATTAuthorizationWithTimeoutInterval(_ seconds: TimeInterval) {
        
    }
    
    /// Stop event tracking manually
    public static func stopTracking() {
        do {
            try self.checkIfInitialzed(shared)
            
            self.removeTrackers()
        }
        catch AirConfigError.notInitialized {
            fatalError(AirConfigError.notInitialized.localizedDescription)
        }
        catch let error {
            AirLoggingManager.logger(error: error)
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
        try self.setAndLaunchTrackers()
    }
    
    /// Wraps Initializing routine of the SDK
    /// and configure other instances with the given options
    static private func initializeWithOptions(_ options: AirConfigOptions) throws {
        if self.shared != nil {
            throw AirConfigError.alreadyInitialized
        }
        
        self.shared = AirSDK()
        self.sessionManager.configureWithOptions(options)
        
        if options.autoStartEnabled {
            try self.setAndLaunchTrackers()
        }
    }
    
    /// Start life cycle tracking by making an `AirEventProcessor` instance.
    ///
    /// - SeeAlso: `AirEventProcessor`
    static private func setAndLaunchTrackers() throws {
        if self.airEventProcessor != nil {
            // FIXME: Decide depends on policies
            throw AirConfigError.alreadyStartedTracking
        }
        self.airEventProcessor = AirEventProcessor()
    }
    
    static private func removeTrackers() {
        self.airEventProcessor = nil
        AirLoggingManager.logger(message: "AirSDK is no longer tracking events", domain: "AirSDK.removeTrackers")
    }
}


