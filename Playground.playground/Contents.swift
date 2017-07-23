//: Playground - noun: a place where people can play

import Foundation
import NMBS

do {
	let stations = try downloadStations()

	func findStation(named name: String) -> RailwayStation? {
		return stations.first(where: {$0.originalName == name})
	}

	if let halle = findStation(named: "Halle"), let oudHeverlee = findStation(named: "Oud-Heverlee") {
		 halle.id.lastPathComponent
		oudHeverlee.id.lastPathComponent

		try suggestionsForTrip(from: halle, to: oudHeverlee).forEach { print($0) }
	}
} catch {
	error
}
