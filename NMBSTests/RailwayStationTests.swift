//
//  NMBSTests.swift
//  NMBSTests
//
//  Created by Damiaan on 8/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import XCTest

#if os(macOS)
	@testable import NMBS
#elseif os(iOS)
	@testable import NMBS_iOS
#elseif os(tvOS)
	@testable import NMBS_tvOS
#endif

class RailwayStationTests: XCTestCase {
	
    func testDownloadStationList() throws {
		let stations = try downloadStations()
		XCTAssertGreaterThan(stations.count, 10)
		
		let halle = stations.first {$0.originalName == "Halle"}
		XCTAssertEqual(halle?.name(in: Locale(identifier: "nl")), "Halle")
		XCTAssertEqual(halle?.name(in: Locale(identifier: "fr")), "Hal")
    }
    
    func testRailwayStationDecodingPerformance() throws {
		let jsonData = try Data(contentsOf: nmbsStationSource)
		
        self.measure {
			do {
				try jsonDecoder.decode(iRailStationList.self, from: jsonData)
			} catch {
				XCTFail(error.localizedDescription)
			}
        }
    }
    
}
