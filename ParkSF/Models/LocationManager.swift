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
        self.loadSavedCarLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
    }

    func saveCarLocation() {
        guard let carLocation = self.userLocation else { return }
        let carLocationData = try? NSKeyedArchiver.archivedData(withRootObject: carLocation, requiringSecureCoding: false)
        UserDefaults.standard.set(carLocationData, forKey: "carLocation")
        self.carLocation = carLocation
    }
    
    func deleteCarLocation() {
        UserDefaults.standard.removeObject(forKey: "carLocation")
        self.carLocation = nil
    }
    
    private func loadSavedCarLocation() {
        if let carLocationData = UserDefaults.standard.object(forKey: "carLocation") as? Data,
           let carLocation = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(carLocationData) as? CLLocation {
            self.carLocation = carLocation
        }
    }
}
