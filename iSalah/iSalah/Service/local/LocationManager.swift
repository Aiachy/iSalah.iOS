//
//  LocationManager.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import Foundation
import CoreLocation
import Combine

// Lokasyon bilgisini içeren model
struct LocationInfo {
    let coordinate: CLLocationCoordinate2D
    let country: String?
    let countryCode: String?
    let city: String?
    let district: String?
    let subDistrict: String?
    let streetName: String?
    let postalCode: String?
    let formattedAddress: String?
    let timeZone: TimeZone?
}

// Lokasyon işlemi sonucunu içeren enum
enum LocationResult {
    case success(LocationInfo)
    case failure(LocationError)
}

// Lokasyon hatalarını tanımlayan enum
enum LocationError: Error, LocalizedError {
    case authorizationDenied
    case locationDisabled
    case geocodingFailed
    case networkError
    case timedOut
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .authorizationDenied:
            return "Konum izni reddedildi."
        case .locationDisabled:
            return "Konum servisleri devre dışı."
        case .geocodingFailed:
            return "Konum bilgileri alınamadı."
        case .networkError:
            return "Ağ bağlantısı hatası."
        case .timedOut:
            return "Konum isteği zaman aşımına uğradı."
        case .unknownError:
            return "Bilinmeyen bir hata oluştu."
        }
    }
}

final class LocationManager: NSObject {
    
    // MARK: - Properties
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var completionHandler: ((LocationResult) -> Void)?
    private var locationTimer: Timer?
    private let timeoutInterval: TimeInterval = 15.0 // 15 saniye
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    // MARK: - Public Methods
    
    /// Kullanıcının detaylı lokasyon bilgilerini alır
    /// - Parameter completion: Lokasyon sonucunu döndüren closure
    func getUserLocation(completion: @escaping (LocationResult) -> Void) {
        self.completionHandler = completion
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            completion(.failure(.authorizationDenied))
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationUpdates()
        @unknown default:
            completion(.failure(.unknownError))
        }
    }
    
    /// Lokasyon servislerini durdurur
    func stopLocationServices() {
        locationManager.stopUpdatingLocation()
        invalidateTimer()
    }
    
    // MARK: - Private Methods
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 10 metre
    }
    
    private func startLocationUpdates() {
        locationManager.startUpdatingLocation()
        startTimer()
    }
    
    private func startTimer() {
        invalidateTimer()
        locationTimer = Timer.scheduledTimer(timeInterval: timeoutInterval, 
                                             target: self, 
                                             selector: #selector(locationTimedOut), 
                                             userInfo: nil, 
                                             repeats: false)
    }
    
    private func invalidateTimer() {
        locationTimer?.invalidate()
        locationTimer = nil
    }
    
    @objc private func locationTimedOut() {
        stopLocationServices()
        completionHandler?(.failure(.timedOut))
    }
    
    private func reverseGeocodeLocation(_ location: CLLocation) {
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self = self else { return }
            
            self.stopLocationServices()
            
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                self.completionHandler?(.failure(.geocodingFailed))
                return
            }
            
            guard let placemark = placemarks?.first else {
                self.completionHandler?(.failure(.geocodingFailed))
                return
            }
            
            let locationInfo = LocationInfo(
                coordinate: location.coordinate,
                country: placemark.country,
                countryCode: placemark.isoCountryCode,
                city: placemark.administrativeArea, // İl
                district: placemark.locality, // İlçe
                subDistrict: placemark.subLocality, // Mahalle
                streetName: placemark.thoroughfare, // Cadde/Sokak
                postalCode: placemark.postalCode,
                formattedAddress: self.formatAddress(from: placemark),
                timeZone: placemark.timeZone
            )
            
            self.completionHandler?(.success(locationInfo))
        }
    }
    
    func formatAddress(from placemark: CLPlacemark) -> String {
        // Adres bileşenlerini bir araya getirme
        var addressComponents: [String] = []
        
        if let subThoroughfare = placemark.subThoroughfare {
            addressComponents.append(subThoroughfare)
        }
        
        if let thoroughfare = placemark.thoroughfare {
            addressComponents.append(thoroughfare)
        }
        
        if let subLocality = placemark.subLocality {
            addressComponents.append(subLocality)
        }
        
        if let locality = placemark.locality {
            addressComponents.append(locality)
        }
        
        if let administrativeArea = placemark.administrativeArea {
            addressComponents.append(administrativeArea)
        }
        
        if let postalCode = placemark.postalCode {
            addressComponents.append(postalCode)
        }
        
        if let country = placemark.country {
            addressComponents.append(country)
        }
        
        return addressComponents.joined(separator: ", ")
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationUpdates()
        case .denied, .restricted:
            completionHandler?(.failure(.authorizationDenied))
        case .notDetermined:
            // Kullanıcı henüz seçim yapmadı
            break
        @unknown default:
            completionHandler?(.failure(.unknownError))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last, location.horizontalAccuracy >= 0 else { return }
        
        // Yeterince kesin bir lokasyon elde edildiğinde güncellemeyi durdur
        if location.horizontalAccuracy <= 100 { // 100 metre hassasiyet
            // Lokasyonu güncellemeyi durdur ve adres bilgisini al
            reverseGeocodeLocation(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        stopLocationServices()
        
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                completionHandler?(.failure(.authorizationDenied))
            case .network:
                completionHandler?(.failure(.networkError))
            default:
                completionHandler?(.failure(.unknownError))
            }
        } else {
            completionHandler?(.failure(.unknownError))
        }
    }
}
