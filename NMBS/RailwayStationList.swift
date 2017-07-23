//
//  nmbsStationList.swift
//  NMBS
//
//  Created by Damiaan on 22/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import Foundation

struct iRailStationList: Decodable {
	enum CodingKeys: String, CodingKey {
		case stations = "@graph"
	}	
	
	let stations: [RailwayStation]
}

let nmbsStationSource = URL(string: "https://irail.be/stations/NMBS")!

// MARK: - Getting railway station info

/// Download all NMBS's railway stations from irail.be
///
/// - Returns: A list with all the NMBS Railway stations
/// - Throws: An error when the download fails
public func downloadStations() throws -> [RailwayStation] {
	let stationsJSON = try Data(contentsOf: nmbsStationSource)
	return try jsonDecoder.decode(iRailStationList.self, from: stationsJSON).stations
}
