//
//  Stations.swift
//  NMBS
//
//  Created by Damiaan on 8/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import Foundation
import CoreLocation

public struct RailwayStation: CustomStringConvertible {

	public let originalName: String
	public let location: CLLocation
	public let iRailID: URL
	
	let translatedName: [Locale:String]
	
	public func name(in userLocale: Locale = Locale.autoupdatingCurrent) -> String {
		return translatedName.first(where: {$0.key.languageCode == userLocale.languageCode})?.value ?? originalName
	}
	
	public var description: String {
		return originalName
	}
}

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
		location = CLLocation(latitude: latitude, longitude: longitude)
		
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
