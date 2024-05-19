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

    var body: some View {
        GeometryReader { geometry in
            VStack {
                MapView(carLocation: $locationManager.carLocation, userLocation: $locationManager.userLocation)
                    .frame(height: geometry.size.height / 3)
                VStack {
                    if let location = locationManager.userLocation {
                        Text("Your location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    }
                    Button(action: {
                        locationManager.saveCarLocation()
                    }) {
                        Text("Save Car Location")
                    }
                    if let carLocation = locationManager.carLocation {
                        Text("Car location: \(carLocation.coordinate.latitude), \(carLocation.coordinate.longitude)")
                    }
                }
                .frame(height: (geometry.size.height / 3) * 2)
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
