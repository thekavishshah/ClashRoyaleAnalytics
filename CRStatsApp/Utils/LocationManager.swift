//
//  LocationManager.swift
//  CRStatsApp
//
//  Created by Kavish Shah on 10/28/25.
//


import Foundation
import CoreLocation
import MapKit

@MainActor
class LocationManager: NSObject, ObservableObject {
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 50, longitudeDelta: 50)
    )
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func requestLocation() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }
    
    func coordinatesForCountry(code: String) -> CLLocationCoordinate2D? {
        let countryCoordinates: [String: CLLocationCoordinate2D] = [
            "US": CLLocationCoordinate2D(latitude: 37.0902, longitude: -95.7129),
            "GB": CLLocationCoordinate2D(latitude: 55.3781, longitude: -3.4360),
            "DE": CLLocationCoordinate2D(latitude: 51.1657, longitude: 10.4515),
            "FR": CLLocationCoordinate2D(latitude: 46.2276, longitude: 2.2137),
            "IT": CLLocationCoordinate2D(latitude: 41.8719, longitude: 12.5674),
            "ES": CLLocationCoordinate2D(latitude: 40.4637, longitude: -3.7492),
            "CA": CLLocationCoordinate2D(latitude: 56.1304, longitude: -106.3468),
            "BR": CLLocationCoordinate2D(latitude: -14.2350, longitude: -51.9253),
            "MX": CLLocationCoordinate2D(latitude: 23.6345, longitude: -102.5528),
            "AR": CLLocationCoordinate2D(latitude: -38.4161, longitude: -63.6167),
            "JP": CLLocationCoordinate2D(latitude: 36.2048, longitude: 138.2529),
            "CN": CLLocationCoordinate2D(latitude: 35.8617, longitude: 104.1954),
            "IN": CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629),
            "RU": CLLocationCoordinate2D(latitude: 61.5240, longitude: 105.3188),
            "AU": CLLocationCoordinate2D(latitude: -25.2744, longitude: 133.7751),
            "KR": CLLocationCoordinate2D(latitude: 35.9078, longitude: 127.7669),
            "TR": CLLocationCoordinate2D(latitude: 38.9637, longitude: 35.2433),
            "SA": CLLocationCoordinate2D(latitude: 23.8859, longitude: 45.0792),
            "AE": CLLocationCoordinate2D(latitude: 23.4241, longitude: 53.8478),
            "PL": CLLocationCoordinate2D(latitude: 51.9194, longitude: 19.1451),
            "NL": CLLocationCoordinate2D(latitude: 52.1326, longitude: 5.2913),
            "SE": CLLocationCoordinate2D(latitude: 60.1282, longitude: 18.6435),
            "NO": CLLocationCoordinate2D(latitude: 60.4720, longitude: 8.4689),
            "DK": CLLocationCoordinate2D(latitude: 56.2639, longitude: 9.5018),
            "FI": CLLocationCoordinate2D(latitude: 61.9241, longitude: 25.7482),
            "CH": CLLocationCoordinate2D(latitude: 46.8182, longitude: 8.2275),
            "AT": CLLocationCoordinate2D(latitude: 47.5162, longitude: 14.5501),
            "BE": CLLocationCoordinate2D(latitude: 50.5039, longitude: 4.4699),
            "PT": CLLocationCoordinate2D(latitude: 39.3999, longitude: -8.2245),
            "GR": CLLocationCoordinate2D(latitude: 39.0742, longitude: 21.8243),
            "CZ": CLLocationCoordinate2D(latitude: 49.8175, longitude: 15.4730),
            "RO": CLLocationCoordinate2D(latitude: 45.9432, longitude: 24.9668),
            "HU": CLLocationCoordinate2D(latitude: 47.1625, longitude: 19.5033),
            "ID": CLLocationCoordinate2D(latitude: -0.7893, longitude: 113.9213),
            "TH": CLLocationCoordinate2D(latitude: 15.8700, longitude: 100.9925),
            "PH": CLLocationCoordinate2D(latitude: 12.8797, longitude: 121.7740),
            "MY": CLLocationCoordinate2D(latitude: 4.2105, longitude: 101.9758),
            "SG": CLLocationCoordinate2D(latitude: 1.3521, longitude: 103.8198),
            "VN": CLLocationCoordinate2D(latitude: 14.0583, longitude: 108.2772),
            "EG": CLLocationCoordinate2D(latitude: 26.8206, longitude: 30.8025),
            "ZA": CLLocationCoordinate2D(latitude: -30.5595, longitude: 22.9375),
            "NG": CLLocationCoordinate2D(latitude: 9.0820, longitude: 8.6753),
            "IL": CLLocationCoordinate2D(latitude: 31.0461, longitude: 34.8516),
            "NZ": CLLocationCoordinate2D(latitude: -40.9006, longitude: 174.8860),
            "CL": CLLocationCoordinate2D(latitude: -35.6751, longitude: -71.5430),
            "CO": CLLocationCoordinate2D(latitude: 4.5709, longitude: -74.2973),
            "PE": CLLocationCoordinate2D(latitude: -9.1900, longitude: -75.0152),
            "UA": CLLocationCoordinate2D(latitude: 48.3794, longitude: 31.1656),
            "IR": CLLocationCoordinate2D(latitude: 32.4279, longitude: 53.6880),
            "IQ": CLLocationCoordinate2D(latitude: 33.2232, longitude: 43.6793),
            "PK": CLLocationCoordinate2D(latitude: 30.3753, longitude: 69.3451)
        ]
        
        return countryCoordinates[code.uppercased()]
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.userLocation = location.coordinate
            self.region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }
}
