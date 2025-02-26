//
//  LocationSuggestion.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import UIKit
import CoreLocation
import MapKit

struct LocationSuggestion: Identifiable, Equatable, Hashable {
    let id = UUID()
    let country: String
    let city: String
    let district: String?
    let coordinate: CLLocationCoordinate2D
    
    var formattedLocation: String {
        if let district = district, !district.isEmpty {
            return "\(district), \(city), \(country)"
        }
        return "\(city), \(country)"
    }
    
    // Equatable implementation için
    static func == (lhs: LocationSuggestion, rhs: LocationSuggestion) -> Bool {
        return lhs.country == rhs.country &&
               lhs.city == rhs.city &&
               lhs.district == rhs.district
    }
    
    // Hashable implementation için
    func hash(into hasher: inout Hasher) {
        hasher.combine(country)
        hasher.combine(city)
        hasher.combine(district)
    }
}
