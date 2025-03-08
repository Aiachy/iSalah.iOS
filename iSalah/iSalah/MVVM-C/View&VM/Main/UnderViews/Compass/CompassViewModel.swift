//
//  CompassViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 28.02.2025.
//

import Foundation
import CoreLocation
import Combine

class CompassViewModel: NSObject, ObservableObject {
    
    // MARK: - Properties
    let coordinator: MainCoordinatorPresenter
    private let locationManager = CLLocationManager()
    
    @Published var isSheetPresented: Bool
    @Published var compassHeading: Float = 0
    @Published var qiblaDirection: Double? = nil
    
    // Coordinates of Kaaba in Mecca
    private let kaabaCoordinate = CLLocationCoordinate2D(
        latitude: 21.4225,
        longitude: 39.8262
    )
    
    // MARK: - Initialization
    init(isSheetPresented: Bool = false,
         coordinator: MainCoordinatorPresenter) {
        self.isSheetPresented = isSheetPresented
        self.coordinator = coordinator
        super.init()
        
        // Setup location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Methods
    func makeBackButton() {
        coordinator.navigate(to: .main)
    }
    
    func startCompassUpdates() {
        // Check if device supports heading (compass)
        if CLLocationManager.headingAvailable() {
            locationManager.startUpdatingHeading()
        }
    }
    
    func stopCompassUpdates() {
        locationManager.stopUpdatingHeading()
    }
    
    func calculateQiblaDirection(for coordinate: CLLocationCoordinate2D?) {
        guard let userCoordinate = coordinate else {
            qiblaDirection = nil
            return
        }
        
        // Implement the North Azimuth Formula for Qibla direction
        // Reference: http://www.geomete.com/abdali/papers/qibla.pdf
        
        // Convert coordinates from degrees to radians
        let userLatRad = userCoordinate.latitude * .pi / 180
        let userLongRad = userCoordinate.longitude * .pi / 180
        let kaabaLatRad = kaabaCoordinate.latitude * .pi / 180
        let kaabaLongRad = kaabaCoordinate.longitude * .pi / 180
        
        // Difference in longitude
        let longDiff = kaabaLongRad - userLongRad
        
        // Calculate Qibla direction (angle from North)
        let term1 = sin(longDiff)
        let term2 = cos(userLatRad) * tan(kaabaLatRad)
        let term3 = sin(userLatRad) * cos(longDiff)
        
        let qiblaAngleRad = atan2(term1, term2 - term3)
        
        // Convert to degrees
        var qiblaAngleDeg = qiblaAngleRad * 180 / .pi
        
        // Normalize to 0-360
        if qiblaAngleDeg < 0 {
            qiblaAngleDeg += 360
        }
        
        print("Calculated Qibla direction: \(qiblaAngleDeg)° from North")
        
        DispatchQueue.main.async {
            // In SwiftUI, 0° is to the right (East) and increases clockwise
            // In navigation, 0° is North and increases clockwise
            // So we need to add 90° to convert from navigation to SwiftUI coordinate system
            self.qiblaDirection = qiblaAngleDeg + 90
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension CompassViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Use trueHeading if available, otherwise use magneticHeading
        let heading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        
        DispatchQueue.main.async {
            print("Compass heading updated: \(heading)°")
            self.compassHeading = Float(heading)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Compass error: \(error.localizedDescription)")
    }
}
