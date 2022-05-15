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
    static var airEventDecoder: AirEventDecoder?
    
    static var networkManager = AirNetworkManager.shared
    static var deeplinkManager = AirDeeplinkManager.shared
    
    // MARK: - Public methods
    
    /// Initializes AirSDK
    ///
    /// Configures a default AirSDK instance.
    /// Raises an error if any configuration step fails.
    ///
    /// - Warning: This method **should be called from the main thread**.
    public static func configure() {
        do {
            if self.shared != nil {
                throw AirConfigError.alreadyInitialized
            }
                        
            self.shared = AirSDK()
            self.airEventDecoder = AirEventDecoder()
            
            AirLoggingManager.logger(message: "AirSDK is initialized", domain: "AirSDK")
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
    
    /// Temporary scheme handler
    ///
    /// Raises an error if any step fails.
    public static func handleSchemeLink(_ url: URL) {
        do {
            try checkIfInitialzed(shared)
            deeplinkManager.handleSchemeLink(url)
        } catch AirConfigError.notInitialized {
            fatalError(AirConfigError.notInitialized.localizedDescription)
        } catch let error {
            AirLoggingManager.logger(error: error)
        }
    }
    
    /// Temporary universal link handler
    ///
    /// Raises an error if any step fails.
    public static func handleUniversalLink(_ url: URL) {
        do {
            try checkIfInitialzed(shared)
            deeplinkManager.handleUniversalLink(url)
        } catch AirConfigError.notInitialized {
            fatalError(AirConfigError.notInitialized.localizedDescription)
        } catch let error {
            AirLoggingManager.logger(error: error)
        }
    }
    
    // MARK: - Internal methods
    /// Checks if SDK has been initialized properly
    static func checkIfInitialzed(_ instance: AirSDK?) throws {
        // What if whether configured or not doesn't matter?
        if instance == nil {
            throw AirConfigError.notInitialized
        }
    }
}


