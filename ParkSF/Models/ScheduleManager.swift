//
//  ScheduleManager.swift
//  ParkSF
//
//  Created by Samuel Li on 5/21/24.
//

import Foundation
import Combine

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

class ScheduleManager: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var streetSweepingSchedule: [StreetSweepingInfo] = []
    @Published var errorMessage: String?
    
    func getStreetSweepingSchedule(streetNumber: String, streetName: String) {
        self.fetchCNNForAddress(streetNumber: streetNumber, streetName: streetName)
    }
    
    func deleteSchedule() {
        self.streetSweepingSchedule.removeAll()
        self.errorMessage = nil
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
