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

    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        guard let carLocation = carLocation else { return }
        let annotation = MKPointAnnotation()
        annotation.coordinate = carLocation.coordinate
        uiView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: carLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        uiView.setRegion(region, animated: true)
    }
}

//#Preview {
//    MapView()
//}
