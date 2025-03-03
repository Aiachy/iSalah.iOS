//
//  TodayPrayerModel.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import Foundation

struct TodayPrayerModel: Identifiable, Equatable {
    var id: String
    var title: String
    var subTitle: String
    var arabic: String
    var reading: String
    var meal: String
    
    // Static equality comparison
    static func == (lhs: TodayPrayerModel, rhs: TodayPrayerModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Default empty prayer to avoid nil values
    static let empty = TodayPrayerModel(
        id: "empty",
        title: "No Prayer Available",
        subTitle: "",
        arabic: "",
        reading: "",
        meal: "Please check your connection or try again later."
    )
    
    // Validate that all required fields have content
    var isValid: Bool {
        return !id.isEmpty && !title.isEmpty && !arabic.isEmpty && !meal.isEmpty
    }
}
