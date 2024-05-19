//
//  MenuView.swift
//  ParkSF
//
//  Created by Samuel Li on 1/17/24.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject var locationManager = LocationManager()

    var body: some View {
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
                MapView(carLocation: $locationManager.carLocation)
                    .frame(height: 300)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
