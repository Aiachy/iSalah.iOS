//
//  GreatingDaysModel.swift
//  iSalah
//
//  Created by Mert Türedü on 8.03.2025.
//

import SwiftUI

struct GreatingDaysModel: Identifiable {
    let id: Int
    let name: LocalizedStringKey
    let date: Date
    
    var untilDay: String {
        abs(date.daysUntil()).formatted()
    }
    
    var IsPastTime: Bool {
        date.daysUntil() < 0
    }
}
