import Foundation
import RevenueCat
import SwiftUI

// MARK: - RevenueCat Yöneticisi
final class RevenueCatManager: NSObject {
    // Singleton
    static let shared = RevenueCatManager()
    
    // Durumlar
    var packages: [SubscriptionPackage] = []
    var isLoading: Bool = false
    private var currentTask: Task<Void, Never>?
    
    // Zaman aşımı süresi
    private let timeoutDuration: Double = 5.0 // 5 saniye
    
    // Özel başlatıcı
    private override init() {
        super.init()
        print("🔶 RevenueCatManager: RevenueCat Starting")
        setupRevenueCat()
    }
    
    // RevenueCat setup
    private func setupRevenueCat() {
        Purchases.configure(withAPIKey: "appl_NQOVlatBEYhVBLntAAKviUDjUAp")
        Purchases.shared.delegate = self
        
    }
}

// MARK: - Subs Handling
extension RevenueCatManager {
    func checkSubscriptionStatus() async -> (hasSubscription: Bool, premiumType: String?) {
          do {
              let customerInfo = try await Purchases.shared.customerInfo()
              let hasActiveSubscription = customerInfo.entitlements.active.count > 0
              
              // Get the premium type from the first active entitlement (if any)
              var premiumType: String? = nil
              if hasActiveSubscription, let firstEntitlement = customerInfo.entitlements.active.first {
                  premiumType = firstEntitlement.key
              }
              
              await MainActor.run {
                  print("🔶 RevenueCatManager: Subscription status: \(hasActiveSubscription ? "Active" : "Not active"), Type: \(premiumType ?? "None")")
              }
              
              return (hasActiveSubscription, premiumType)
          } catch {
              print("🔶 RevenueCatManager: Failed to check subscription status: \(error.localizedDescription)")
              return (false, nil)
          }
      }
}

// MARK: - Paket İşlemleri
extension RevenueCatManager {
    // Paket tekliflerini yükle
    func loadPackages() async {
        print("🔶 Paketler yükleniyor")
        isLoading = true
        packages = []
        
        do {
            let offerings = try await Purchases.shared.offerings()
            
            guard let currentOffering = offerings.current else {
                print("🔶 Hiç paket bulunamadı")
                isLoading = false
                return
            }
            
            // Paketleri SubscriptionPackage modeline dönüştür
            await MainActor.run {
                var newPackages: [SubscriptionPackage] = []
                
                for rcPackage in currentOffering.availablePackages {
                    let product = rcPackage.storeProduct
                    let packageType = getPackageType(from: rcPackage)
                    let durationDays = getDurationDays(from: packageType)
                    
                    let subscriptionPackage = SubscriptionPackage(
                        id: rcPackage.identifier,
                        productId: product.productIdentifier,
                        title: product.localizedTitle,
                        price: product.price as Decimal,
                        localizedPrice: product.localizedPriceString,
                        durationDays: durationDays,
                        type: packageType
                    )
                    
                    newPackages.append(subscriptionPackage)
                    print("🔶 Paket eklendi: \(subscriptionPackage.title)")
                }
                
                // Paketleri süre sırasına göre sırala
                packages = newPackages.sorted { $0.durationDays < $1.durationDays }
                isLoading = false
            }
        } catch {
            print("🔶 Paketler yüklenemedi: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    // RevenueCat paket tipini bizim paket tipimize çevir
    private func getPackageType(from package: RevenueCat.Package) -> SubscriptionPackage.PackageType {
        switch package.packageType {
        case .weekly:
            return .custom(days: 7)
        case .monthly:
            return .monthly
        case .annual:
            return .yearly
        case .lifetime:
            return .lifetime
        default:
            // Diğer paket tipleri
            if package.identifier.contains("lifetime") {
                return .lifetime
            } else if package.identifier.contains("year") {
                return .yearly
            } else if package.identifier.contains("month") {
                return .monthly
            } else if package.identifier.contains("week") {
                return .custom(days: 7)
            } else {
                return .custom(days: 30) // Varsayılan
            }
        }
    }
    
    // Paket tipinden süre (gün olarak) hesapla
    private func getDurationDays(from packageType: SubscriptionPackage.PackageType) -> Int {
        switch packageType {
        case .monthly:
            return 30
        case .yearly:
            return 365
        case .lifetime:
            return 36500 // ~100 yıl
        case .custom(let days):
            return days
        }
    }
}

// MARK: - Satın Alma İşlemleri
extension RevenueCatManager {
  
    func purchase(_ package: SubscriptionPackage) async throws -> CustomerInfo {
        print("🔶 RevenueCatManager: Purchasing package: \(package.title)")
        
        // Cancel any previous running task
        currentTask?.cancel()
        
        
        // Purchase operation with timeout
        do {
            return try await withTimeout(seconds: timeoutDuration) {
                guard let offering = try await Purchases.shared.offerings().current,
                      let rcPackage = offering.package(identifier: package.id) else {
                    print("🔶 RevenueCatManager: Package not found")
                    throw NSError(domain: "RevenueCatManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Package not found"])
                }
                
                print("🔶 RevenueCatManager: Starting purchase transaction...")
                let purchaseResult = try await Purchases.shared.purchase(package: rcPackage)
                
                await MainActor.run {
                    print("🔶 RevenueCatManager: Purchase successful, active subscriptions: \(purchaseResult.customerInfo.entitlements.active.count)")
                }
                
                return purchaseResult.customerInfo
            }
        } catch {
            print("🔶 RevenueCatManager: Purchase failed with error: \(error.localizedDescription)")
            
            // Enhance error message for common issues
            let enhancedError: Error
            if (error as NSError).code == 408 {
                // Already a timeout error, pass through
                enhancedError = error
            } else if (error as NSError).domain == "SKErrorDomain" {
                // App Store specific error
                enhancedError = NSError(
                    domain: "RevenueCatManager",
                    code: (error as NSError).code,
                    userInfo: [NSLocalizedDescriptionKey: "App Store error: \(error.localizedDescription). Please try again later."]
                )
            } else {
                // Generic error
                enhancedError = NSError(
                    domain: "RevenueCatManager",
                    code: (error as NSError).code,
                    userInfo: [NSLocalizedDescriptionKey: "Purchase failed: \(error.localizedDescription)"]
                )
            }
            throw enhancedError
        }
    }
    
    func restorePurchases() async throws {
        print("🔶 Satın alımlar geri yükleniyor")
        
        // Önceki çalışan işlemi iptal et
        currentTask?.cancel()
        
        return try await withTimeout(seconds: timeoutDuration) {
            let customerInfo = try await Purchases.shared.restorePurchases()
            
            await MainActor.run {
                print("🔶 Geri yükleme başarılı")
            }
            
            return
        }
    }
}

// MARK: - Yardımcı Metotlar
extension RevenueCatManager {
    private func withTimeout<T>(seconds: Double, operation: @escaping () async throws -> T) async throws -> T {
        // Increase timeout duration
        let timeoutDuration: Double = 15.0 // Increased from 5.0 to 15.0 seconds
        
        return try await withCheckedThrowingContinuation { continuation in
            // Execute the operation
            currentTask = Task {
                do {
                    let result = try await operation()
                    if !Task.isCancelled {
                        continuation.resume(returning: result)
                    }
                } catch {
                    if !Task.isCancelled {
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            // Separate task for timeout
            Task {
                try? await Task.sleep(nanoseconds: UInt64(timeoutDuration * 1_000_000_000))
                
                if !Task.isCancelled && currentTask != nil && !currentTask!.isCancelled {
                    currentTask?.cancel()
                    
                }
            }
        }
    }
}

// MARK: - RevenueCat Delegate
extension RevenueCatManager: PurchasesDelegate {
    func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            print("🔶 Müşteri bilgileri güncellendi")
        }
    }
}
