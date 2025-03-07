//
//  GoogleAdManager.swift
//  iSalah
//
//  Created by Mert Türedü on 4.03.2025.
//


import SwiftUI
import GoogleMobileAds
import UIKit

/// A comprehensive manager for handling Google Mobile Ads in SwiftUI
final class GoogleAdManager: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    /// Indicates if an ad is currently being presented
    @Published var isAdPresenting = false
    
    /// Indicates if the initialization process has completed
    @Published var isInitialized = false
    
    // MARK: - Singleton Instance
    
    /// Shared instance for accessing the ad manager throughout the app
    static let shared = GoogleAdManager()
    
    // MARK: - Private Properties
    
    /// Current interstitial ad instance
    private var interstitial: InterstitialAd?
    
    /// Current rewarded ad instance
    private var rewardedAd: RewardedAd?
    
    /// Queue for safely handling ad operations
    private let adQueue = DispatchQueue(label: "com.isalah.adqueue")
    
    /// Reward handler closure for rewarded ads
    private var rewardHandler: ((AdReward) -> Void)?
    
    /// Tracks when ads were last shown to prevent excessive display
    private var lastAdPresentTime: Date? = nil
    
    /// Minimum time interval between displaying ads (in seconds)
    private let minimumAdInterval: TimeInterval = 60
    
    // MARK: - Test Ad Unit IDs
    
    /// Test ad unit IDs for development purposes
    private let testAdUnitIDs = [
        "banner": "ca-app-pub-3940256099942544/2934735716",
        "interstitial": "ca-app-pub-3940256099942544/4411468910",
        "rewarded": "ca-app-pub-3940256099942544/1712485313"
    ]
    
    // MARK: - Production Ad Unit IDs
    
    /// Production ad unit IDs for release builds
    private let productionAdUnitIDs = [
        "banner": "ca-app-pub-8700718147094077~5096096771",
        "interstitial": "ca-app-pub-8700718147094077~5096096771",
        "rewarded": "YOUR_REWARDED_AD_UNIT_ID"
    ]
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        setupMobileAds()
    }
    
    /// Sets up the Google Mobile Ads SDK
    private func setupMobileAds() {
        // Initialize the Google Mobile Ads SDK
        MobileAds.shared.start { [weak self] status in
            guard let self = self else { return }
            
            // Log initialization status
            print("Mobile ads initialization complete with status: \(status)")
            
            // Prepare initial ad instances
            self.loadInterstitialAd()
            self.loadRewardedAd()
            
            // Update initialization status
            DispatchQueue.main.async {
                self.isInitialized = true
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// Determines which ad unit IDs to use based on build configuration
    private func getAdUnitID(for adType: String) -> String {
        #if DEBUG
        return testAdUnitIDs[adType] ?? ""
        #else
        return productionAdUnitIDs[adType] ?? ""
        #endif
    }
    
    /// Checks if enough time has passed since the last ad was shown
    private func canShowAd() -> Bool {
        guard let lastTime = lastAdPresentTime else { return true }
        return Date().timeIntervalSince(lastTime) >= minimumAdInterval
    }
    
    /// Updates the time when an ad was last presented
    private func updateLastAdPresentTime() {
        lastAdPresentTime = Date()
    }
    
    // MARK: - Banner Ad Methods
    
    /// Creates a banner ad view with the specified size
    func createBannerView(adSize: AdSize = AdSizeBanner) -> BannerView {
        let bannerView = BannerView(adSize: adSize)
        bannerView.adUnitID = getAdUnitID(for: "banner")
        return bannerView
    }
    
    /// Loads an ad into the provided banner view
    func loadBannerAd(for bannerView: BannerView, rootViewController: UIViewController) {
        bannerView.rootViewController = rootViewController
        bannerView.load(Request())
    }
    
    // MARK: - Interstitial Ad Methods
    
    /// Loads an interstitial ad
    private func loadInterstitialAd() {
        let adUnitID = getAdUnitID(for: "interstitial")
        
        InterstitialAd.load(with: adUnitID, request: Request()) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
                return
            }
            
            self.interstitial = ad
            self.interstitial?.fullScreenContentDelegate = self
            print("Interstitial ad loaded successfully")
        }
    }
    
    /// Shows an interstitial ad if available
    func showInterstitialAd(from rootViewController: UIViewController, completion: (() -> Void)? = nil) {
        adQueue.async { [weak self] in
            guard let self = self, self.isInitialized else {
                DispatchQueue.main.async { completion?() }
                return
            }
            
            // Check if ad can be shown based on time interval
            if !self.canShowAd() {
                DispatchQueue.main.async { completion?() }
                return
            }
            
            DispatchQueue.main.async {
                self.isAdPresenting = true
                
                if let interstitialAd = self.interstitial {
                    interstitialAd.present(from: rootViewController)
                    self.updateLastAdPresentTime()
                } else {
                    print("Interstitial ad not ready yet")
                    self.isAdPresenting = false
                    completion?()
                    // Try loading a new ad for next time
                    self.loadInterstitialAd()
                }
            }
        }
    }
    
    // MARK: - Rewarded Ad Methods
    
    /// Loads a rewarded ad
    func loadRewardedAd() {
        let adUnitID = getAdUnitID(for: "rewarded")
        
        RewardedAd.load(with: adUnitID, request: Request()) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Failed to load rewarded ad: \(error.localizedDescription)")
                return
            }
            
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
            print("Rewarded ad loaded successfully")
        }
    }
    
    /// Shows a rewarded ad if available
    func showRewardedAd(from rootViewController: UIViewController, rewardHandler: @escaping (AdReward) -> Void, completion: (() -> Void)? = nil) {
        adQueue.async { [weak self] in
            guard let self = self, self.isInitialized else {
                DispatchQueue.main.async { completion?() }
                return
            }
            
            // Check if ad can be shown based on time interval
            if !self.canShowAd() {
                DispatchQueue.main.async { completion?() }
                return
            }
            
            self.rewardHandler = rewardHandler
            
            DispatchQueue.main.async {
                self.isAdPresenting = true
                
                if let rewardedAd = self.rewardedAd {
                    rewardedAd.present(from: rootViewController) { [weak self] in
                        // User earned reward
                        guard let self = self else { return }
                        let reward = rewardedAd.adReward
                        print("Reward earned: \(reward.amount) \(reward.type)")
                        self.rewardHandler?(reward)
                    }
                    self.updateLastAdPresentTime()
                } else {
                    print("Rewarded ad not ready yet")
                    self.isAdPresenting = false
                    completion?()
                    // Try loading a new ad for next time
                    self.loadRewardedAd()
                }
            }
        }
    }
}

// MARK: - GADFullScreenContentDelegate
extension GoogleAdManager: FullScreenContentDelegate {
    
    
    /// Called when an ad is shown fullscreen
//    func adDidPresentFullScreenContent(_ ad: FullScreenPresentingAd) {
//        print("Ad presented full screen content")
//        isAdPresenting = true
//    }
    
    /// Called when an ad is dismissed
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        print("Ad dismissed full screen content")
        isAdPresenting = false
        
        // Reload ads for next use
        if ad is InterstitialAd {
            loadInterstitialAd()
        } else if ad is RewardedAd {
            loadRewardedAd()
        }
    }
    
    /// Called when an ad fails to present
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present full screen content with error: \(error.localizedDescription)")
        isAdPresenting = false
        
        // Reload ads for next use
        if ad is InterstitialAd {
            loadInterstitialAd()
        } else if ad is RewardedAd {
            loadRewardedAd()
        }
    }
}

// MARK: - SwiftUI Banner Ad View
struct BannerAdView: UIViewRepresentable {
    var adSize: AdSize
    var adUnitID: String?
    
    init(adSize: AdSize = AdSizeFluid, adUnitID: String? = nil) {
        self.adSize = adSize
        self.adUnitID = adUnitID
    }
    
    func makeUIView(context: Context) -> BannerView {
        let bannerView = GoogleAdManager.shared.createBannerView(adSize: adSize)
        if let customAdUnitID = adUnitID {
            bannerView.adUnitID = customAdUnitID
        }
        return bannerView
    }
    
    func updateUIView(_ bannerView: BannerView, context: Context) {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            return
        }
        
        GoogleAdManager.shared.loadBannerAd(for: bannerView, rootViewController: rootViewController)
    }
}

// MARK: - Ad View Modifiers
extension View {
    /// Presents an interstitial ad when the specified condition is true
    func interstitialAd(_ isPresented: Binding<Bool>, isP isPremium: Bool) -> some View {
        self.modifier(InterstitialAdViewModifier(isPresented, isPremium: isPremium ))
    }
    
    /// Presents a rewarded ad when the specified condition is true
    func rewardedAd(isPresented: Binding<Bool>, rewardHandler: @escaping (AdReward) -> Void) -> some View {
        self.modifier(RewardedAdViewModifier(isPresented: isPresented, rewardHandler: rewardHandler))
    }
}

// MARK: - View Modifiers for Ads
struct InterstitialAdViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    let isPremium: Bool
    
    init(
        _ isPresented: Binding<Bool>,
        isPremium: Bool
    ) {
        _isPresented = isPresented
        self.isPremium = isPremium
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                guard !isPremium else { return }
                if newValue {
                    showInterstitialAd()
                }
            }
    }
    
    private func showInterstitialAd() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            isPresented = false
            return
        }
        
        GoogleAdManager.shared.showInterstitialAd(from: rootViewController) {
            isPresented = false
        }
    }
}

struct RewardedAdViewModifier: ViewModifier {
    @Binding var isPresented: Bool
    var rewardHandler: (AdReward) -> Void
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isPresented) { newValue in
                if newValue {
                    showRewardedAd()
                }
            }
    }
    
    private func showRewardedAd() {
        guard let rootViewController = UIApplication.shared.windows.first?.rootViewController else {
            isPresented = false
            return
        }
        
        GoogleAdManager.shared.showRewardedAd(from: rootViewController, rewardHandler: rewardHandler) {
            isPresented = false
        }
    }
}
