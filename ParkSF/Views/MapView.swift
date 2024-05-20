//
//  MapView.swift
//    display map centered on user location
//  ParkSF
//
//  Created by Samuel Li on 1/16/24.
//

import SwiftUI
import MapKit

// Extend CLLocationCoordinate2D to conform to Equatable
extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

struct MapView: UIViewRepresentable {
    @Binding var carLocation: CLLocation? {
        didSet {
            if oldValue?.coordinate != carLocation?.coordinate {
                // When carLocation changes, trigger the update to remove annotations and add the new one
                updateAnnotations(for: carLocation)
            }
        }
    }
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
                updateAnnotations(for: carLocation, in: uiView)
                region = MKCoordinateRegion(center: carLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            } else if let userLocation = userLocation {
                uiView.removeAnnotations(uiView.annotations)
                region = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
            } else {
                uiView.removeAnnotations(uiView.annotations)
                let defaultLocation = CLLocationCoordinate2D(latitude: 37.770319, longitude: -122.443818)
                region = MKCoordinateRegion(center: defaultLocation, latitudinalMeters: 8000, longitudinalMeters: 8000)
            }

            uiView.setRegion(region, animated: true)
        }
    }
    
    private func updateAnnotations(for location: CLLocation?, in mapView: MKMapView? = nil) {
        guard let location = location else { return }
        let annotation = MKPointAnnotation()
        annotation.coordinate = location.coordinate

        if let mapView = mapView {
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
        }
    }
}

//#Preview {
//    MapView()
//}
