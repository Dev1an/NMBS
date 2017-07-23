//
//  TripSuggestions.swift
//  NMBS
//
//  Created by Damiaan on 22/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import Foundation

enum SuggestionDecodingError: Error {
	case versionMismatch(DecodingError.Context)
}

struct Suggestions: Decodable {
	static let codingVersion = "1.1"
	
	enum CodingKeys: String, CodingKey {
		case version, connection
	}
	
	let trips: [Trip]
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		let version = try container.decode(String.self, forKey: .version)
		guard version == Suggestions.codingVersion else {
			throw SuggestionDecodingError
				.versionMismatch(
					DecodingError.Context(
						codingPath: [CodingKeys.version],
						debugDescription: "Got version \(version) but expected \(Suggestions.codingVersion)"
					)
				)
		}
		
		var trips = [Trip]()
		var connection = try container.nestedUnkeyedContainer(forKey: .connection)
		while (!connection.isAtEnd) {
			trips.append(try connection.decode(Trip.self))
		}
		self.trips = trips
	}
}

enum TripSuggestionError: Error {
	case cannotConstructURL
}

// MARK: - Getting Directions

/// Get suggestions for the best trips from one railway station to another
///
/// Suggestions come from: https://hello.irail.be/api/1-0/
///
/// - Parameters:
///   - start: The RailwayStation of the departure station
///   - end: The RailwayStation of the arrival station
/// - Returns: an Array with suggested trips
/// - Throws: When an error occurs while requesting the suggested trips
public func suggestionsForTrip(from start: RailwayStation, to end: RailwayStation) throws -> [Trip] {
	return try suggestionsForTrip(from: start.id, to: end.id)
}

/// Get suggestions for the best trips from one railway station to another
///
/// Suggestions come from: https://hello.irail.be/api/1-0/
///
/// - Parameters:
///   - start: The id of the departure station
///   - end: The id of the arrival station
/// - Returns: an Array with suggested trips
/// - Throws: When an error occurs while requesting the suggested trips
public func suggestionsForTrip(from start: RailwayStation.iRailID, to end: RailwayStation.iRailID) throws -> [Trip] {
	return try suggestionsForTrip(from: start.lastPathComponent, to: end.lastPathComponent)
}

/// Get suggestions for the best trips from one railway station to another.
///
/// Suggestions come from: [iRail](https://hello.irail.be/api/1-0/)
///
/// - Parameters:
///   - start: The last path component of the id of the departure station
///   - end: The last path component of the id of the arrival station
/// - Returns: an Array with suggested trips
/// - Throws: When an error occurs while requesting the suggested trips
public func suggestionsForTrip(from start: String, to end: String) throws -> [Trip] {
	guard let url = URL(string: "https://api.irail.be/connections/?from=\(start)&to=\(end)&format=json") else {
		throw TripSuggestionError.cannotConstructURL
	}
	let json = try Data(contentsOf: url)
	return try jsonDecoder.decode(Suggestions.self, from: json).trips
}
