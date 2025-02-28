//
//  SubscriptionPackage.swift
//  iSalah
//
//  Created by Mert Türedü on 28.02.2025.
//

import SwiftUI
import StoreKit

// MARK: - Abonelik Paketi Modeli
struct SubscriptionPackage: Identifiable, Hashable {
    let id: String
    let productId: String
    let title: String
    let price: Decimal
    let localizedPrice: String
    let durationDays: Int
    let type: PackageType
    
    // Paket tipleri
    enum PackageType: Hashable {
        case monthly
        case yearly
        case lifetime
        case custom(days: Int)
    }
    
    // Süre metni (UI için)
    var durationText: String {
        switch type {
        case .monthly:
            return "Aylık"
        case .yearly:
            return "Yıllık"
        case .lifetime:
            return "Ömür Boyu"
        case .custom(let days):
            if days == 7 {
                return "Haftalık"
            } else {
                return "\(days) Günlük"
            }
        }
    }
    
    // Günlük maliyet
    var dailyCost: Double {
        if durationDays <= 0 || type == .lifetime {
            return 0.0
        }
        return (price as NSDecimalNumber).doubleValue / Double(durationDays)
    }
    
    // Paket tasarrufu (aylık paket ile karşılaştırma)
    func savingsPercentage(comparedTo monthlyPackage: SubscriptionPackage?) -> Int? {
        guard let monthly = monthlyPackage,
              monthly.type == .monthly,
              self.type != .monthly,
              self.type != .lifetime else {
            return nil
        }
        
        let equivalentMonthlyPrice = (monthly.price as NSDecimalNumber).doubleValue * (Double(self.durationDays) / 30.0)
        let saving = equivalentMonthlyPrice - (self.price as NSDecimalNumber).doubleValue
        let percentage = (saving / equivalentMonthlyPrice) * 100
        
        // Yüzdeyi tam sayıya yuvarla
        return percentage > 0 ? Int(percentage.rounded()) : nil
    }
}
