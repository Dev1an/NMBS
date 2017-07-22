//: Playground - noun: a place where people can play

import Cocoa
import NMBS

func findStation(named name: String) -> RailwayStation? {
	return stations.first(where: {$0.originalName == name})
}

let stations = try! downloadStations()
if let halle = findStation(named: "Halle"), let leuven = findStation(named: "Leuven") {
	 halle.iRailID.lastPathComponent
	leuven.iRailID.lastPathComponent
}
