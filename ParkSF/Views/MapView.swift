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
    @Binding var shouldCenter: Bool

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            parent.shouldCenter = false
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if shouldCenter {
            let region: MKCoordinateRegion

            if let carLocation = carLocation {
                let annotation = MKPointAnnotation()
                annotation.coordinate = carLocation.coordinate
                uiView.addAnnotation(annotation)
                region = MKCoordinateRegion(center: carLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            } else if let userLocation = userLocation {
                // TODO: detect change in car location to delete previous annotations
                uiView.removeAnnotations(uiView.annotations)
                region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            } else {
                // TODO: detect change in car location to delete previous annotations
                uiView.removeAnnotations(uiView.annotations)
                let defaultLocation = CLLocationCoordinate2D(latitude: 37.770319, longitude: -122.443818)
                region = MKCoordinateRegion(center: defaultLocation, latitudinalMeters: 8000, longitudinalMeters: 8000)
            }

            uiView.setRegion(region, animated: true)
        }
    }
}

//#Preview {
//    MapView()
//}
