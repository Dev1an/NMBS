//
//  NMBSTests.swift
//  NMBSTests
//
//  Created by Damiaan on 8/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import XCTest
@testable import NMBS

class NMBSTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDownloadStationList() {
		do {
			let stations = try NMBS.downloadStations()
			XCTAssertGreaterThan(stations.count, 10)
			print(stations.last)
		} catch {
			XCTFail(error.localizedDescription)
		}
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
