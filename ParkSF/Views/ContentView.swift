//
//  MenuView.swift
//  ParkSF
//
//  Created by Samuel Li on 1/17/24.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @State private var shouldCenter = true

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack {
                    MapView(carLocation: $locationManager.carLocation, userLocation: $locationManager.userLocation, shouldCenter: $shouldCenter)
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                shouldCenter = true
                            }) {
                                Image(systemName: "location.circle.fill")
                                    .resizable()
                                    .frame(width: 44, height: 44)
                                    .background(Color.white.opacity(0.7))
                                    .clipShape(Circle())
                                    .padding()
                            }
                        }
                    }
                }
                VStack {
                    if let location = locationManager.userLocation {
                        Text("Your location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    }
                    Button(action: {
                        locationManager.scheduleManager.deleteSchedule()
                        locationManager.saveCarLocation()
                        shouldCenter = true
                    }) {
                        Text("Save Car Location")
                    }
                    if let carLocation = locationManager.carLocation {
                        Text("Car location: \(carLocation.coordinate.latitude), \(carLocation.coordinate.longitude)")
                        Button(action: {
                            locationManager.scheduleManager.deleteSchedule()
                            locationManager.deleteCarLocation()
                            shouldCenter = true
                        }) {
                            Text("Delete Car Location")
                        }
                        if let carAddress = locationManager.carAddress {
                            Text("Car address: \(carAddress)")
                        }
                        if !locationManager.scheduleManager.streetSweepingSchedule.isEmpty {
                            Text("Street Sweeping Schedule:")
                            ForEach(locationManager.scheduleManager.streetSweepingSchedule, id: \.fullname) { info in
                                Text("\(info.fullname ?? ""): \(info.fromhour ?? "") - \(info.tohour ?? "")")
                            }
                        }
                        if let errorMessage = locationManager.scheduleManager.errorMessage {
                            Text("Error: \(errorMessage)")
                                .foregroundColor(.red)
                                .padding()
                        }
                    }
                }
                .frame(height: geometry.size.height * 0.66)
                .padding()
            }
            .ignoresSafeArea(edges: .all)
        }
    }
}

#Preview {
    ContentView()
}
