//
//  ParkedLocation.swift
//  ParkSF
//
//  Created by Samuel Li on 1/16/24.
//

import SwiftUI
import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var cancellables = Set<AnyCancellable>()

    @Published var userLocation: CLLocation?
    @Published var carLocation: CLLocation?
    @Published var carAddress: String?
    @Published var streetSweepingSchedule: [StreetSweepingInfo] = []
    @Published var errorMessage: String?
    
    private var streetNumber: String?
    private var streetName: String?

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
        self.streetSweepingSchedule.removeAll()
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
                    self?.fetchCNNForAddress(streetNumber: streetNumber, streetName: streetName)
                }
            } else {
                self?.carAddress = "Unknown address"
            }
        }
    }
    
    private func fetchCNNForAddress(streetNumber: String, streetName: String) {
        let urlString = "https://data.sfgov.org/resource/pu5n-qu5c.json?$$app_token=nqS61NppjFrVHrr6txZLqiYGO&streetname=\(streetName.uppercased())&$where=((lf_fadd<=\(streetNumber) AND lf_tadd>=\(streetNumber))OR(rt_fadd<=\(streetNumber) AND rt_tadd>=\(streetNumber)))"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL for fetching CNN."
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .decode(type: [StreetData].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to fetch CNN for address: \(error.localizedDescription), URL String: \(urlString)"
                }
            }, receiveValue: { [weak self] streetData in
                guard let self = self else { return }
                self.determineSideAndFetchSweepingSchedule(for: streetData, addressNumber: streetNumber)
            })
            .store(in: &cancellables)
    }
    
    private func determineSideAndFetchSweepingSchedule(for streetData: [StreetData], addressNumber: String) {
        guard let addressNumberInt = Int(addressNumber) else {
            self.errorMessage = "Invalid address number."
            return
        }

        // Filter street data to find the correct entry based on parity of the address number
        let filteredStreetData = streetData.filter { street in
            guard let leftSide = Int(street.lf_fadd ?? ""), let rightSide = Int(street.rt_fadd ?? "") else {
                self.errorMessage = "Invalid address number or street data."
                return false
            }
            if leftSide != 0 {
                return addressNumberInt % 2 == leftSide % 2
            } else {
                return addressNumberInt % 2 == rightSide % 2
            }
        }

        guard let street = filteredStreetData.first else {
            self.errorMessage = "No matching street data found for the address."
            return
        }
        
        let leftSide = Int(street.lf_fadd ?? "0")!
        let side = (addressNumberInt % 2 == leftSide % 2) && (leftSide != 0) ? "L" : "R"
        fetchStreetSweepingSchedule(cnn: street.cnn, side: side)
    }

    private func fetchStreetSweepingSchedule(cnn: String, side: String) {
        let urlString = "https://data.sfgov.org/resource/yhqp-riqs.json?$$app_token=nqS61NppjFrVHrr6txZLqiYGO&cnn=\(cnn)&cnnrightleft=\(side)"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL for fetching street sweeping schedule."
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result -> Data in
                guard let response = result.response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return result.data
            }
            .decode(type: [StreetSweepingInfo].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = "Failed to fetch street sweeping schedule: \(error.localizedDescription)"
                }
            }, receiveValue: { [weak self] scheduleData in
                guard let self = self else { return }
                if scheduleData.isEmpty {
                    self.errorMessage = "No street sweeping data found for the location."
                } else {
                    self.streetSweepingSchedule = scheduleData
                }
            })
            .store(in: &cancellables)
    }
}

struct StreetData: Codable {
    let cnn: String
    let streetname: String?
    let lf_fadd: String?
    let rt_fadd: String?
}

struct StreetSweepingInfo: Codable {
    let fullname: String?
    let fromhour: String?
    let tohour: String?
}
