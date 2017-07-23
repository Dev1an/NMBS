//
//  Stations.swift
//  NMBS
//
//  Created by Damiaan on 8/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import Foundation
import CoreLocation


/// Basic information of a railway station provided by iRail
public struct RailwayStation: Codable, CustomStringConvertible {

	// MARK: - Type aliases
	
	/// iRail defined url that defines an NMBS railway station
	///
	/// **Example** http://irail.be/stations/NMBS/007015400
	public typealias iRailID = URL
	
	// MARK: - Instance properties
	
	/// The name of the station in the original language
	public let originalName: String
	
	/// 2D coordinate indicating the geographical location of the railway station
	public let location: CLLocationCoordinate2D
	
	/// A unique url for the railway station defined by the iRail project.
	public let id: iRailID
	
	let translatedName: [Locale:String]
	
	// MARK: - Computed properties
	
	/// Translate the name in a specified locale
	///
	/// - Parameter userLocale: Optional object containing the desired language. If no locale is provided the user's locale will be used.
	/// - Returns: The name of the station in the specified locale's language
	public func name(in userLocale: Locale = Locale.autoupdatingCurrent) -> String {
		return translatedName.first(where: {$0.key.languageCode == userLocale.languageCode})?.value ?? originalName
	}
	
	/// The name of the station in the user locale's language
	public var description: String {
		return name()
	}
}

extension RailwayStation {
	enum IRailDecodingError: Error {
		case unableToParseLatitude(String), unableToParseLongitude(String), unableToParseID(String)
	}
	
	init(from station: iRailStationList.Station) throws {
		guard let latitude = CLLocationDegrees(station.latitude) else {
			throw IRailDecodingError.unableToParseLatitude(station.latitude)
		}
		guard let longitude = CLLocationDegrees(station.latitude) else {
			throw IRailDecodingError.unableToParseLatitude(station.latitude)
		}
		guard let id = iRailID(string: station.id) else {
			throw RailwayStation.IRailDecodingError.unableToParseID(station.id)
		}
		self.id = id
		location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		originalName = station.name
		if let alternatives = station.alternatives {
			var translatedName = [Locale:String]()
			for translation in alternatives {
				translatedName[Locale(identifier: translation.language)] = translation.value
			}
			self.translatedName = translatedName
		} else {
			self.translatedName = [:]
		}
	}
}

extension CLLocationCoordinate2D: Codable {
	public init(from decoder: Decoder) throws {
		var container = try decoder.unkeyedContainer()
		self.init(
			latitude: try container.decode(CLLocationDegrees.self),
			longitude: try container.decode(CLLocationDegrees.self)
		)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.unkeyedContainer()
		try container.encode(latitude)
		try container.encode(longitude)
	}
}
