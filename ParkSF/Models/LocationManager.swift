//
//  ParkedLocation.swift
//  ParkSF
//
//  Created by Samuel Li on 1/16/24.
//

import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocation: CLLocation?
    @Published var carLocation: CLLocation?

    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
    }

    func saveCarLocation() {
        self.carLocation = self.userLocation
    }
}
