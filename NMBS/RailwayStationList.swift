//
//  nmbsStationList.swift
//  NMBS
//
//  Created by Damiaan on 22/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import Foundation

struct iRailStationList: Codable {
	enum CodingKeys: String, CodingKey {
		case stations = "@graph"
	}
	
	struct Station: Codable {
		enum CodingKeys: String, CodingKey {
			case name
			case id = "@id"
			case alternatives = "alternative"
			case latitude = "http://www.w3.org/2003/01/geo/wgs84_pos#lat"
			case longitude = "http://www.w3.org/2003/01/geo/wgs84_pos#long"
		}
		
		struct Alternative: Codable {
			enum CodingKeys: String, CodingKey {
				case language = "@language", value = "@value"
			}
			
			let language, value: String
		}
		
		let id, name, latitude, longitude: String
		let alternatives: [Alternative]?
	}
	
	let stations: [Station]
}

let nmbsStationSource = URL(string: "https://irail.be/stations/NMBS")!

// MARK: - Getting railway station info


/// Response to an asynchronous request
public enum Response<T> {
	/// The request has been processed succesfully and the resulted `data` is available
	case success(data: T)
	/// An error occured while processing the request
	case exception(Error)
}

/// An error that occurs while fetching information from iRail.be
public enum NetworkError: Error {
	/// There was no data returned and no error information is available.
	case noDataResponse
}


/// Download all NMBS's railway stations from irail.be
///
/// - Parameter completionHandler: A closure receving either a list of stations or an exception
public func downloadStations(completionHandler: @escaping (Response<[RailwayStation]>)->Void ) {
	let task = URLSession.shared.dataTask(with: nmbsStationSource) { data, _, possibleError in
		if let error = possibleError {
			completionHandler(.exception(error))
		} else if let stationsJSON = data {
			do {
				let stationsList = try jsonDecoder.decode(iRailStationList.self, from: stationsJSON).stations.map {try RailwayStation(from: $0)}
				completionHandler(.success(data: stationsList))
			} catch {
				completionHandler(.exception(error))
			}
		} else {
			completionHandler(.exception(NetworkError.noDataResponse))
		}
	}
	task.resume()
}
