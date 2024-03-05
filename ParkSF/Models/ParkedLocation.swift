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
    
    init(location: CLLocationCoordinate2D, addr:String) {
        self.location = location
        self.addr = addr
    }
}

extension ParkedLocation {
    static let sampleData: ParkedLocation =
    ParkedLocation(location: CLLocationCoordinate2D(latitude: 37.790131, longitude: -122.427368),
                   addr: "1939–1999 Octavia St, San Francisco, CA  94109, United States")
}
