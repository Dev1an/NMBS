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
public struct RailwayStation: CustomStringConvertible {
	/// iRail defined url that defines an NMBS railway station
	///
	/// **Example** http://irail.be/stations/NMBS/007015400
	public typealias ID = URL
	
	// MARK: - Instance properties
	
	/// The name of the station in the original language
	public let originalName: String
	
	/// 2D coordinate indicating the geographical location of the railway station
	public let location: CLLocationCoordinate2D
	
	/// A unique url for the railway station defined by the iRail project.
	public let iRailID: ID
	
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

// MARK: - Decoding Extension

extension RailwayStation: Decodable {
	enum CodingKeys: String, CodingKey {
		case originalName = "name"
		case iRailID = "@id"
		case latitude
		case longitude
		case alternative
	}
	
	enum AlternativeNameCodingKeys: String, CodingKey {
		case language = "@language"
		case value = "@value"
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		originalName = try container.decode(String.self, forKey: .originalName)
		iRailID = try container.decode(URL.self, forKey: .iRailID)
		
		let latitude = CLLocationDegrees(try container.decode(String.self, forKey: .latitude))!
		let longitude = CLLocationDegrees(try container.decode(String.self, forKey: .longitude))!
		location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
		
		if container.contains(.alternative) {
			var alternativeNamesArray = try container.nestedUnkeyedContainer(forKey: .alternative)
			var names = [Locale:String]()
			while !alternativeNamesArray.isAtEnd {
				let object = try alternativeNamesArray.nestedContainer(keyedBy: AlternativeNameCodingKeys.self)
				let locale = Locale(identifier: try object.decode(String.self, forKey: .language))
				let name = try object.decode(String.self, forKey: .value)
				names[locale] = name
			}
			translatedName = names
		} else {
			translatedName = [:]
		}
	}
}
