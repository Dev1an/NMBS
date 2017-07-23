//
//  TripTests.swift
//  NMBSTests
//
//  Created by Damiaan on 23/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import XCTest
@testable import NMBS

class TripTests: XCTestCase {
	
	enum TestError: Error {
		case invalidRailwayStationID
	}
	
    func testSuggestions() throws {
		guard let halle = URL(string: "http://irail.be/stations/NMBS/008814308") else { throw TestError.invalidRailwayStationID }
		guard let oudHeverlee = URL(string: "http://irail.be/stations/NMBS/008814308") else { throw TestError.invalidRailwayStationID }
		let suggestedTrips = try suggestionsForTrip(from: halle, to: oudHeverlee)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
