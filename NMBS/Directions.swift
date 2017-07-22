//
//  Directions.swift
//  NMBS
//
//  Created by Damiaan on 22/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import Foundation

public struct Trip: Decodable {
	public let stops: [TrainStop]
	
	public struct TrainStop: Decodable {
		let place: RailwayStation
		let platform: String
		let time: Date
		let trainDirection: RailwayStation
	}
}

enum TripSuggestionError: Error {
	case cannotConstructURL
}

/// Get suggestions for the best trips from one railway station to another
///
/// Suggestions come from: https://hello.irail.be/api/1-0/
///
/// - Parameters:
///   - start: The iRailID of the departure station
///   - end: The iRailID of the arrival station
/// - Returns: an Array with suggested trips
/// - Throws: When an error occurs while requesting the suggested trips
public func getSuggestionsForTrip(from start: URL, to end: URL) throws -> [Trip] {
	guard let url = URL(string: "https://api.irail.be/connections/?from=\(start.lastPathComponent)&to=\(end.lastPathComponent)&format=json") else {
		throw TripSuggestionError.cannotConstructURL
	}
	let json = try Data(contentsOf: url)
	return try jsonDecoder.decode([Trip].self, from: json)
}
