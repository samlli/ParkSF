//
//  ParkedLocation.swift
//  ParkSF
//
//  Created by Samuel Li on 1/16/24.
//

import Foundation
import CoreLocation

struct ParkedLocation {
    var location: CLLocationCoordinate2D
    var addr: String
    var sweepDay: String
    var sweepFromHr: Int
    var sweepToHr: Int
//    var sweepWeeks: [Int]
//    var sweepHoliday: Int
    
    init(location: CLLocationCoordinate2D, addr: String, sweepDay: String, sweepFromHr: Int, sweepToHr: Int) {
        self.location = location
        self.addr = addr
        self.sweepDay = sweepDay
        self.sweepFromHr = sweepFromHr
        self.sweepToHr = sweepToHr
    }
}

extension ParkedLocation {
    static let sampleData: ParkedLocation =
    ParkedLocation(location: CLLocationCoordinate2D(latitude: 37.790228, longitude: -122.427573),
                   addr: "1939 Octavia St, San Francisco, CA  94109, United States",
                   sweepDay: "Wed",
                   sweepFromHr: 9,
                   sweepToHr: 11)
}
