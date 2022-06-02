//
//  EventTrafficController.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/31.
//

import Foundation

/// You should know about the SDK's event emitting policy to understand how this it works.
/// There're 3 events to be handled:
///     - `Custom`
///     - `System`
///     - `Install`
///
/// And there're 2 ways to emit the events *manually*:
///     - `startTracking`
///     - `ATTtimeout`
///
/// Basically, SDK always emits `Custom` events unless the user deactivate tracking deliberately
/// and if SDK is auto-started, which means the user doesn't change any of the `AirConfigOptions`,
/// it emits all queued events: `Custom`, `System`, `Install`.
///
/// However, it goes tricky to handle when `autoStartEnabled` is set to false.
///
/// In this condition, at the point that `startTracking` is activated,  SDK will be emitting `System` along with `Custom` event.
/// You should catch that `Install` events are not still emitted yet.
/// It's because to increase the chances of getting IDFA, we decided to block `Install` event from emitting
/// until the app user allow the ATT authorization.
/// Or if `ATTtimeout` is over, SDK emits the event to prevent SDK from holding the event all day long.
///
/// Anyway, at the point that either of two restrictions are resolved, SDK will be emitting an `Install` event this time.
/// In here, you should catch the SDK emits **only the `Install` event**.
///
/// This is probably the most confusing thing in the SDK policy.
/// In a nutshell you only need to know `ATTtimeout` event only affects to the `Install` event.
/// For example,
///     - The user didn't do`startTracking` but set `ATTtimeout`,  **only** `Install` event is emitted
///     - The user did do `startTracking` and set `ATTtimeout`, `System` events are emitted and
///     `Install` event is emitted too **when timeout is over**.
///     - The user did `startTracking` and didn't set `ATTtimeout`, `System` events are emitted and `Install` event is **not emitted**.
///
/// It's hell of tricky thing so... good luck!
///
/// - SeeAlso: `AirConfigOptions`
/// - SeeAlso: `AirSDK`

class EventTrafficController {
    weak var delegate: EventTrafficControllerDelegate? {
        didSet {
            self.setNotifications()
            self.delegate?.customEventDidBecomeEmitable()
        }
    }
    
    @objc func startTracking() {
        self.delegate?.systemEventDidBecomeEmitable()
    }
    
    @objc func nowATTtimeoutIsOver() {
        self.delegate?.installEventDidBecomeEmitable()
    }
    
    @objc func stopTracking(sendCustomEvent: Bool = true) {
        self.delegate?.trackingDidBecomeDisabled()
    }
    
    // MARK: - Private methods
    
    private func setNotifications() {
        TrafficNotificationCenter.default.addObserver(self,
                                                      selector: #selector(self.startTracking),
                                                      name: TrafficNotification.start.name,
                                                      object: nil)
        
        TrafficNotificationCenter.default.addObserver(self,
                                                      selector: #selector(self.nowATTtimeoutIsOver),
                                                      name: TrafficNotification.timeoutForATT.name,
                                                      object: nil)
        
        TrafficNotificationCenter.default.addObserver(self,
                                                      selector: #selector(self.stopTracking),
                                                      name: TrafficNotification.stop.name,
                                                      object: nil)
    }
}
