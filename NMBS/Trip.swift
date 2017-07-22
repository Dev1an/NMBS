//
//  Directions.swift
//  NMBS
//
//  Created by Damiaan on 22/07/17.
//  Copyright © 2017 Damiaan Dufaux. All rights reserved.
//

import Foundation

public struct TrainStop {
	public let stationID: URL
	public let platform: String
	public let time: Date
	public let delay: TimeInterval
}

public struct MovingTrain {
	public let id: String
	public let direction: String
}

public struct SingleTrainTrip {
	public let train: MovingTrain
	public let startPoint: TrainStop
	public let endPoint: TrainStop
}

public struct Trip: CustomDebugStringConvertible {
	public let trains: [SingleTrainTrip]
	public let duration: TimeInterval
	
	public var debugDescription: String {
		return "Trip: \(trains.first!.startPoint.time) -> \(trains.last!.endPoint.time) (\(trains.count-1) stops)"
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


