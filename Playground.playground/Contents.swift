//: Playground - noun: a place where people can play

import Cocoa
import NMBS

do {
	let stations = try downloadStations()

	func findStation(named name: String) -> RailwayStation? {
		return stations.first(where: {$0.originalName == name})
	}

	if let halle = findStation(named: "Halle"), let leuven = findStation(named: "Oud-Heverlee") {
		 halle.iRailID.lastPathComponent
		leuven.iRailID.lastPathComponent

		let suggestions = try suggestionsForTrip(from: halle, to: leuven)
		suggestions.forEach {
			print($0)
			$0.trains.forEach {
				print("  Spoor \($0.startPoint.platform), richting \($0.train.direction)")
			}
		}
	}
} catch {
	print(error)
}
