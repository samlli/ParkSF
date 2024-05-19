//
//  MapView.swift
//    display map centered on user location
//  ParkSF
//
//  Created by Samuel Li on 1/16/24.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var carLocation: CLLocation?
    @Binding var userLocation: CLLocation?

    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        let region: MKCoordinateRegion
        
        if let carLocation = carLocation {
            let annotation = MKPointAnnotation()
            annotation.coordinate = carLocation.coordinate
            uiView.addAnnotation(annotation)
            region = MKCoordinateRegion(center: carLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        } else if let userLocation = userLocation {
            region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        } else {
            // Default to San Francisco City Hall if both locations are unavailable
            let defaultLocation = CLLocationCoordinate2D(latitude: 37.779268, longitude: -122.419248)
            region = MKCoordinateRegion(center: defaultLocation, latitudinalMeters: 500, longitudinalMeters: 500)
        }

        uiView.setRegion(region, animated: true)
    }
}

//#Preview {
//    MapView()
//}
