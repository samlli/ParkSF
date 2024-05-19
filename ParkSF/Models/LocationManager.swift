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
    private let geocoder = CLGeocoder()

    @Published var userLocation: CLLocation?
    @Published var carLocation: CLLocation?
    @Published var carAddress: String?

    override init() {
        super.init()
//        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
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
        self.reverseGeocodeCarLocation()
    }
    
    func deleteCarLocation() {
        UserDefaults.standard.removeObject(forKey: "carLocation")
        self.carLocation = nil
        self.carAddress = nil
    }
    
    private func loadSavedCarLocation() {
        if let carLocationData = UserDefaults.standard.object(forKey: "carLocation") as? Data,
           let carLocation = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(carLocationData) as? CLLocation {
            self.carLocation = carLocation
            self.reverseGeocodeCarLocation()
        }
    }
    
    private func reverseGeocodeCarLocation() {
    guard let carLocation = carLocation else { return }
    geocoder.reverseGeocodeLocation(carLocation) { [weak self] (placemarks, error) in
        if let error = error {
            print("Reverse geocode failed: \(error.localizedDescription)")
            self?.carAddress = "Unknown address"
            return
        }
        if let placemark = placemarks?.first {
            self?.carAddress = "\(placemark.name ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? "")"
        } else {
            self?.carAddress = "Unknown address"
        }
    }
}
}
