//
//  PaywallViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import Foundation
import SwiftUI

class PaywallViewModel: ObservableObject {
    
    @Published var isAppearPaywall: Bool = false
    @Published var isLoading: Bool = false
    @Published var currentPackage: SubscriptionPackage? = nil
    
    var manager = RevenueCatManager.shared
    
    // Zaman aşımı kontrolü için
    private var restoreTimeoutTask: Task<Void, Never>?
    private let timeoutDuration: Double = 5.0 // 5 saniye
    
    init() {
        makeAppearThat()
        loadPackage()
    }
}

// MARK: Handler
extension PaywallViewModel {
    
    private func makeAppearThat() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.isAppearPaywall = true
        }
    }
    
    var formattedPrice: String {
        if let package = currentPackage {
            return package.localizedPrice
        }
        return "9.99$"
    }
    
    var fullSubscriptionText: String {
        return formattedPrice
    }
}

//MARK: RevenueCat Manager
extension PaywallViewModel {
    private func loadPackage() {
        Task {
            await manager.loadPackages()
            
            await MainActor.run {
                // Sadece bir paket var ve onu kullanıyoruz
                if !manager.packages.isEmpty {
                    currentPackage = manager.packages.first
                    print(
                        "🔶 Paket yüklendi: \(currentPackage?.title ?? "Bilinmeyen")"
                    )
                } else {
                    print("🔶 Hiç paket bulunamadı!")
                }
            }
        }
    }
    
    func purchasePackage() {
        guard let package = currentPackage else {
            return
        }
        
        self.isLoading = true
        
        Task {
            do {
                try await manager.purchase(package)
                await MainActor.run {
                    self.isLoading = false
                    print("🔶 Paket satın alma başarılı")
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print("🔶 Satın alma hatası: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func restorePurchases(result: @escaping (Bool) -> Void) {
        self.isLoading = true
        
        // Önceki zaman aşımı görevini iptal et
        restoreTimeoutTask?.cancel()
        
        Task {
            do {
                try await manager.restorePurchases()
                await MainActor.run {
                    self.isLoading = false
                    print("🔶 Satın alımlar geri yüklendi")
                    result(true)
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print("🔶 Geri yükleme hatası: \(error.localizedDescription)")
                    result(false)
                }
            }
        }
        
        // Yedek zaman aşımı kontrolü
        restoreTimeoutTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(timeoutDuration * 1_000_000_000))
            
            if !Task.isCancelled {
                await MainActor.run {
                    // Eğer hala yükleme durumundaysa, zaman aşımına uğramış demektir
                    if self.isLoading {
                        self.isLoading = false
                        print("🔶 Geri yükleme zaman aşımına uğradı")
                        result(false)
                    }
                }
            }
        }
    }
}
