import Foundation
import SwiftUI
import StoreKit

final class RateUsManager {
    static let shared = RateUsManager()
    
    private enum UserDefaultsKeys {
        static let appLaunchCount = "com.isalah.appLaunchCount"
        static let hasReviewed = "com.isalah.hasReviewed"
        static let reviewPromptCount = "com.isalah.reviewPromptCount"
    }
    
    private var hasReviewed: Bool {
        get { UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasReviewed) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.hasReviewed) }
    }
    
    private var appLaunchCount: Int {
        get { UserDefaults.standard.integer(forKey: UserDefaultsKeys.appLaunchCount) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.appLaunchCount) }
    }
    
    private var reviewPromptCount: Int {
        get { UserDefaults.standard.integer(forKey: UserDefaultsKeys.reviewPromptCount) }
        set { UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.reviewPromptCount) }
    }
    
    private init() {
        appLaunchCount += 1
    }
    
    func hasUserReviewed() -> Bool {
        return hasReviewed
    }
    
    func promptForReviewNow() {
        if reviewPromptCount < 3 {
            reviewPromptCount += 1
            requestReview()
        }
    }
    
    func checkAndPromptForReviewRandomly() {
        guard !hasReviewed && reviewPromptCount < 3 else { return }
        
        if appLaunchCount > 5 {
            let randomValue = Int.random(in: 1...10)
            if randomValue <= 3 {
                reviewPromptCount += 1
                requestReview()
                if reviewPromptCount >= 3 {
                    hasReviewed = true
                }
            }
        }
    }
    
    private func requestReview() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if #available(iOS 14.0, *) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                } else {
                    SKStoreReviewController.requestReview()
                }
            } else {
                SKStoreReviewController.requestReview()
            }
        }
    }
}
