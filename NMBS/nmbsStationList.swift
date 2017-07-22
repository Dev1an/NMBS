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
	
	init(from decoder: Decoder) throws {
		stations = try decoder.container(keyedBy: CodingKeys.self).decode([RailwayStation].self, forKey: .stations)
	}
	
	let stations: [RailwayStation]
}

let nmbsStationSource = URL(string: "https://irail.be/stations/NMBS")!

public func downloadStations() throws -> [RailwayStation] {
	let stationsJSON = try Data(contentsOf: nmbsStationSource)
	
	return try jsonDecoder.decode(iRailStationList.self, from: stationsJSON).stations
}
