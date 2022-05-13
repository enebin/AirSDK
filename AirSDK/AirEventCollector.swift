//
//  AirEventDecoder.swift
//  AirSDK
//
//  Created by 이영빈 on 2022/05/13.
//

import Foundation
import UIKit

class AirEventCollector {
    init() {
        self.setNotifications()
    }
    
    var delegate: EventCollectorDelegate?
    
    func setNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.notifiedAppMovedToBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.notifiedAppCameToForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }

    func notifiedAppDidBecomeInstalled() {
        delegate?.appDidBecomeInstalled()
    }
    
    @objc func notifiedAppCameToForeground() {
        delegate?.appCameToForeground()
    }
    
    @objc func notifiedAppMovedToBackground() {
        delegate?.appMovedToBackground()
    }
}
