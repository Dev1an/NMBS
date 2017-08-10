//
//  Directions.swift
//  NMBS
//
//  Created by Damiaan on 22/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import Foundation

/// A position in time and space where a train stops and people can enter or exit a train
public struct TrainStop {
	/// The iRailID of the railway station
	public let stationID: RailwayStation.iRailID
	/// The platform on which the train will stop
	public let platform: String
	/// The time a train will arrive/depart
	public let time: Date
	/// A time interval that should be added to `time` to get a realistic prediction
	public let delay: TimeInterval
}

/// A train moving in a speciefied direction
public struct MovingTrain {
	/// The id of the train
	public let id: String
	/// The direction the train is moving to
	public let direction: String
}

/// A trip between two railway stations that only uses one train
public struct SingleTrainTrip {
	/// A train riding between `startPoint` and `endPoint`
	public let train: MovingTrain
	/// The start of the trip
	public let startPoint: TrainStop
	/// The end of the trip
	public let endPoint: TrainStop
}

let timeFormatter = DateFormatter()

/// A trip between two railway stations consisting of one or more `SingleTrainTrip`'s
public struct Trip: CustomDebugStringConvertible {
	/// A sequence of trains that will bring you from A to B
	public let trains: [SingleTrainTrip]
	/// The total amount of time needed to get from A to B with the `trains`
	public let duration: TimeInterval
	
	public var debugDescription: String {
		timeFormatter.dateStyle = .none
		timeFormatter.timeStyle = .short
		let departure = timeFormatter.string(from: trains.first!.startPoint.time)
		let arrival = timeFormatter.string(from: trains.last!.endPoint.time)
		let generalInfo = "\(departure) -> \(arrival) (\(trains.count) train\(trains.count==1 ? "":"s"))"
		let allInfo = trains.reduce(generalInfo) { (string, trip) in
			"\(string)\n  Train on platform \(trip.startPoint.platform) to \(trip.train.direction)"
		}
		return allInfo
	}
}

extension Trip: Decodable {
	enum CodingKeys: String, CodingKey {
		case duration, departure, arrival, vias
	}
		
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		
		guard let duration = TimeInterval(try container.decode(String.self, forKey: .duration)) else {
			throw DecodingError.dataCorrupted(
				DecodingError.Context(
					codingPath: [CodingKeys.duration],
					debugDescription: "Unable to convert duration string to TimeInterval"
				)
			)
		}
		self.duration = duration
		
		let firstStop = try container.decode(BoundingStop.self, forKey: .departure)
		let lastStop = try container.decode(BoundingStop.self, forKey: .arrival)

		if container.contains(.vias) {
			var lastDeparture = try firstStop.trainStop()
			var trains = [SingleTrainTrip]()
			
			for stop in try container.decode(Vias.self, forKey: .vias).via {
				trains.append(
					SingleTrainTrip(train: MovingTrain(id: stop.vehicle, direction: stop.direction.name), startPoint: lastDeparture, endPoint: try stop.arrivalTrainStop())
				)
				lastDeparture = try stop.departureTrainStop()
			}
			
			trains.append(
				SingleTrainTrip(train: MovingTrain(id: lastStop.vehicle, direction: lastStop.direction.name), startPoint: lastDeparture, endPoint: try lastStop.trainStop())
			)
			self.trains = trains
		} else {
			trains = [
				SingleTrainTrip(
					train: MovingTrain(id: firstStop.vehicle, direction: firstStop.direction.name),
					startPoint: try firstStop.trainStop(),
					endPoint: try lastStop.trainStop()
				)
			]
		}
	}
}


