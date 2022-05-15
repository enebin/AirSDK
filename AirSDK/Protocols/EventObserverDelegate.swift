//
//  LifeCycleTracker.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/10.
//

import Foundation

protocol EventObserverDelegate {
    func appDidBecomeInstalled()
    func appMovedToBackground()
    func appCameToForeground()
}
