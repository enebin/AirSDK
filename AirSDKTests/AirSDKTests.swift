//
//  AirSDKTests.swift
//  AirSDKTests
//
//  Created by 이영빈 on 2022/05/09.
//

import XCTest
@testable import AirSDK

class AirSDKTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testStoredWrapper() throws {
        for _ in 1...10 {
            var manager = EventStorageManager()
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
