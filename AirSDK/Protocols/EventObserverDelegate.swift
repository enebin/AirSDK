//
//  LifeCycleTracker.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/10.
//

import Foundation

protocol EventObserverDelegate: AnyObject {
    func appDidBecomeInstalled()
    func appDidBecomeActive()
    func appCameToForegroundWithDeeplink()
    func appMovedToBackground()
    func didReceiveCustomEvent(_ event: TrackableEvents.customEvent)
}
