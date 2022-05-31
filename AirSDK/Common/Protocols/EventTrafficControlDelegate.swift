//
//  EventTrafficDelegate.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/31.
//

import Foundation

protocol EventTrafficControllerDelegate: AnyObject {
    func systemEventDidBecomeEmitable()
    func customEventDidBecomeEmitable()
    func installEventDidBecomeEmitable()
    func trackingDidBecomeDisabled()
}
