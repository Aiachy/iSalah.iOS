//
//  PaywallViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import Foundation
import RevenueCat
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
    
    func purchasePackage(result: @escaping (Bool) -> ()) {
        guard let package = currentPackage else {
            print("🔶 PaywallViewModel: No package selected")
            result(false)
            return
        }
        
        self.isLoading = true
        print("🔶 PaywallViewModel: Starting purchase process...")
        
        Task {
            do {
                // Perform the purchase with retry mechanism
                var retryCount = 0
                var customerInfo: CustomerInfo? = nil
                var lastError: Error? = nil
                
                // Try up to 2 times (initial attempt + 1 retry)
                while retryCount < 2 && customerInfo == nil {
                    do {
                        if retryCount > 0 {
                            print("🔶 PaywallViewModel: Retrying purchase (attempt \(retryCount + 1))")
                            // Small delay before retry
                            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                        }
                        
                        customerInfo = try await manager.purchase(package)
                    } catch {
                        lastError = error
                        print("🔶 PaywallViewModel: Purchase attempt \(retryCount + 1) failed: \(error.localizedDescription)")
                        
                        // Only retry on timeout or network errors
                        let nsError = error as NSError
                        if nsError.code != 408 && nsError.localizedDescription.lowercased().contains("network") == false {
                            break // Don't retry for other errors
                        }
                    }
                    
                    retryCount += 1
                }
                
                // Check if we successfully got customer info
                if let customerInfo = customerInfo {
                    let hasActiveSubscription = customerInfo.entitlements.active.count > 0
                    
                    await MainActor.run {
                        self.isLoading = false
                        print("🔶 PaywallViewModel: Purchase completed, Premium status: \(hasActiveSubscription)")
                        
                        // Return true if there's an active subscription, false otherwise
                        result(hasActiveSubscription)
                    }
                } else {
                    // We failed after all attempts
                    await MainActor.run {
                        self.isLoading = false
                        let errorMessage = lastError?.localizedDescription ?? "Unknown error"
                        print("🔶 PaywallViewModel: Purchase failed after \(retryCount) attempts: \(errorMessage)")
                        result(false)
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print("🔶 PaywallViewModel: Purchase error: \(error.localizedDescription)")
                    result(false)
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
