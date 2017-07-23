//
//  TrainStop.swift
//  NMBS
//
//  Created by Damiaan on 22/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import Foundation

struct StationInfo: Codable {
	enum CodingKeys: String, CodingKey { case id = "@id" }
	let id: URL
}

struct Direction: Codable { let name: String }

enum StringDecodingError: Error {
	case invalidDelay, invalidTime
}

struct BoundingStop: Codable {
	let delay: String
	let stationinfo: StationInfo
	let time: String
	let platform: String
	let vehicle: String
	let direction: Direction
	
	func trainStop() throws -> TrainStop {
		guard let delay = TimeInterval(delay) else {throw StringDecodingError.invalidDelay}
		guard let time = TimeInterval(time) else {throw StringDecodingError.invalidTime}
		return TrainStop(stationID: stationinfo.id, platform: platform, time: Date(timeIntervalSince1970: time), delay: delay)
	}
}

struct Vias: Codable {
	struct Via: Codable {
		struct Stop: Codable {
			let time: String
			let delay: String
			let platform: String
			
			func trainStop(in station: URL) throws -> TrainStop {
				guard let delay = TimeInterval(delay) else {throw StringDecodingError.invalidDelay}
				guard let time = TimeInterval(time) else {throw StringDecodingError.invalidTime}
				return TrainStop(stationID: station, platform: platform, time: Date(timeIntervalSince1970: time), delay: delay)
			}
		}
		
		let arrival: Stop
		let departure: Stop
		
		let stationinfo: StationInfo
		let vehicle: String
		let direction: Direction
		
		func departureTrainStop() throws -> TrainStop { return try departure.trainStop(in: stationinfo.id) }
		func arrivalTrainStop() throws -> TrainStop { return try arrival.trainStop(in: stationinfo.id) }
	}

	let via: [Via]
}
