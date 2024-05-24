//
//  LocationManager.swift
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
    
    private var streetNumber: String?
    private var streetName: String?
    
    var scheduleManager = ScheduleManager()

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
        if let carLocationData = UserDefaults.standard.object(forKey: "carLocation") as? Data {
            do {
                if let carLocation = try NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: carLocationData) {
                    self.carLocation = carLocation
                    self.reverseGeocodeCarLocation()
                }
            } catch {
                print("Failed to unarchive car location: \(error.localizedDescription)")
            }
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
                self?.streetNumber = placemark.subThoroughfare
                self?.streetName = placemark.thoroughfare
                if let streetNumber = self?.streetNumber, let streetName = self?.streetName {
                    self?.carAddress = "\(streetNumber) \(streetName)"

                    // Check if streetNumber is a range matching the pattern "[number]-[number]"
                    let pattern = #"^(\d+)-(\d+)$"#
                    if let regex = try? NSRegularExpression(pattern: pattern),
                       let match = regex.firstMatch(in: streetNumber, range: NSRange(location: 0, length: streetNumber.utf16.count)) {
                        if let range1 = Range(match.range(at: 1), in: streetNumber),
                           let range2 = Range(match.range(at: 2), in: streetNumber),
                           let num1 = Int(streetNumber[range1]),
                           let num2 = Int(streetNumber[range2]) {
                            // Get middle of range, round down to even
                            let averageStreetNumber = num1 + (((num2 - num1) / 2) & ~1)
                            self?.scheduleManager.getStreetSweepingSchedule(streetNumber: String(averageStreetNumber), streetName: streetName)
                        }
                    } else  {
                        self?.scheduleManager.getStreetSweepingSchedule(streetNumber: streetNumber, streetName: streetName)
                    }
                }
            } else {
                self?.carAddress = "Unknown address"
            }
        }
    }
}
