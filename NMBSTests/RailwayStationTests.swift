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
		let expectation = XCTestExpectation(description: "Download all stations and check the station of Halle is included with correct translations")

		downloadStations {
			switch $0 {

			case .success(let stations):
				XCTAssertGreaterThan(stations.count, 10)

				let halle = stations.first {$0.originalName == "Halle"}
				XCTAssertEqual(halle?.name(in: Locale(identifier: "nl")), "Halle")
				XCTAssertEqual(halle?.name(in: Locale(identifier: "fr")), "Hal")
			case .exception(let error):
				XCTFail(error.localizedDescription)
			}
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 10)
    }
    
    func testRailwayStationDecodingPerformance() throws {
		let jsonData = try Data(contentsOf: nmbsStationSource)
		
        self.measure {
			do {
				let _ = try jsonDecoder.decode(iRailStationList.self, from: jsonData)
			} catch {
				XCTFail(error.localizedDescription)
			}
        }
    }
    
}
