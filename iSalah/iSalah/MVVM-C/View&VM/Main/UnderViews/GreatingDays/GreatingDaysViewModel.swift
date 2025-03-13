//
//  GreatingDaysViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 28.02.2025.
//

import Foundation
import SwiftUI

class GreatingDaysViewModel: ObservableObject {
    
    let coordinator: MainCoordinatorPresenter
    
    @Published var daysByYear: [Int: [GreatingDaysModel]] = [:]
    @Published var availableYears: [Int] = []
    @Published var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @Published var isHidingBeforeDays: Bool
    
    init(coordinator: MainCoordinatorPresenter,
         isHidingBeforeDays: Bool = true) {
        self.coordinator = coordinator
        self.isHidingBeforeDays = isHidingBeforeDays
    }
    
    /// Load all greeting days data
    func loadData() {
        daysByYear = GreatingDaysData.getAllDays()
        
        availableYears = daysByYear.keys.sorted()
        
        // Set selected year to current year if available, otherwise to the first available year
        if let currentYear = availableYears.first(where: { $0 == Calendar.current.component(.year, from: Date()) }) {
            selectedYear = currentYear
        } else if let firstYear = availableYears.first {
            selectedYear = firstYear
        }
        
        // Sort days within each year by date
        for (year, days) in daysByYear {
            daysByYear[year] = days.sorted { $0.date < $1.date }
        }
    }
}

extension GreatingDaysViewModel {
    
    func makeBackButton() {
        coordinator.navigate(to: .main)
    }
    
}
