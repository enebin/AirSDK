//
//  EventTrafficController.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/31.
//

import Foundation

/// A controller class that decides queue's behavior
///
/// To understand how this class works, you should know about the SDK's event emitting policy.
/// There're 3 event types to be handled:
/// - `Custom`
/// - `System`
/// - `Install`
///
/// And there're 2 ways we(or users) can use to emit the events *manually*:
/// - `startTracking`
/// - `ATTtimeout`
///
/// Basically, SDK always emits `Custom` events unless the user deactivate tracking.
/// Besides, if SDK is auto-started, which means the user hasn't changed any of default `AirConfigOptions`,
/// it will emit all queued event types: `Custom`, `System`, `Install`.
///
/// However, it goes tricky to handle when `autoStartEnabled` is set to `false`.
/// In this condition, at the point that `startTracking` is activated, SDK will be emitting `System` events along with `Custom` events.
/// You should remember that `Install` events are still not emitted.
///
/// It's just because of our business policy.
/// To increase chances of getting IDFA, we've decided to block `Install`event  until the user grants the ATT permission.
/// In addition, to prevent the apps from keeping an `Install` event too much,
/// we've brough a *timeout* system to the SDK.
/// For that, you can use `ATTtimeout`. Simpy put, when it's over, SDK emits the event.
///
/// Anyway, at the point that either of two restrictions(granting permission or timeout) are resolved,
/// SDK will be emitting an `Install` event this time.
/// In here, you should notice that the SDK emits **only the `Install` event**.
///
/// It is probably the most confusing thing among the all SDK policies.
/// In a nutshell you only need to remember that `ATTtimeout` event only affects to the `Install` event.
/// Here're some examples:
/// - The user didn't `startTracking` but set `ATTtimeout`,  **only** `Install` event is emitted
/// - The user did `startTracking` and set `ATTtimeout`, `System` events are emitted and
///         `Install` event is emitted too **when timeout is over**.
/// - The user did `startTracking` and didn't set `ATTtimeout`, `System` events are emitted and `Install` event is **not emitted**.
///
/// - SeeAlso: `AirConfigOptions`
/// - SeeAlso: `AirSDK`
///
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
