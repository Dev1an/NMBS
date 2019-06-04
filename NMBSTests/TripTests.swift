//
//  TripTests.swift
//  NMBSTests
//
//  Created by Damiaan on 23/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import XCTest
import CoreLocation

#if os(macOS)
@testable import NMBS
#elseif os(iOS)
@testable import NMBS_iOS
#elseif os(tvOS)
@testable import NMBS_tvOS
#endif

class TripTests: XCTestCase {
	
	enum TestError: Error {
		case invalidRailwayStationID
	}
	
    func testSuggestions() throws {
		guard let halleId = URL(string: "http://irail.be/stations/NMBS/008814308") else { throw TestError.invalidRailwayStationID }
		guard let oudHeverleeId = URL(string: "http://irail.be/stations/NMBS/008833134") else { throw TestError.invalidRailwayStationID }

		let expectation = XCTestExpectation()

		let halle = RailwayStation(originalName: "Halle", location: CLLocationCoordinate2D(latitude: 0, longitude: 0), id: halleId, translatedName: [:])
		let oudHeverlee = RailwayStation(originalName: "Oud-Heverlee", location: CLLocationCoordinate2D(latitude: 0, longitude: 0), id: oudHeverleeId, translatedName: [:])

		suggestionsForTrip(from: halle, to: oudHeverlee) {
			switch $0 {
			case .success(let data):
				XCTAssertGreaterThan(data.count, 0)
			case .exception(let error):
				XCTFail(error.localizedDescription)
			}
			expectation.fulfill()
		}

		wait(for: [expectation], timeout: 10)
    }

}
