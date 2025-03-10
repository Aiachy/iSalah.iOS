//
//  Mock.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import Foundation
import CoreLocation

let civrilLocation = LocationSuggestion(
    country: "Turkey",
    city: "Denizli",
    district: "Çivril",
    coordinate: CLLocationCoordinate2D(latitude: 38.3019, longitude: 29.7387)
)

let mockInfo: UserInfoModel = .init(isPremium: true, gender: "", premiumType: "")

let user: UserModel = .init(info: mockInfo ,location: nil)

let mockSalah: iSalahState = .init(user: user)
