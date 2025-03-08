//
//  PrayShareManager.swift
//  iSalah
//
//  Created on 27.02.2025.
//

import SwiftUI

/// A simple manager for sharing prayer information to WhatsApp and other platforms
class PrayShareManager {
    
    static let shared = PrayShareManager()
    
    private init() {}
    
    /// Share a prayer to WhatsApp or other platforms
    /// - Parameter prayer: The prayer to share
    func sharePrayer(_ prayer: TodayPrayerModel) {
        let formattedText = createShareText(for: prayer)
        shareText(formattedText)
    }
    
    /// Creates a nicely formatted text from a prayer model
    /// - Parameter prayer: The prayer model to format
    /// - Returns: Formatted text ready for sharing
    private func createShareText(for prayer: TodayPrayerModel) -> String {
        var shareText = ""
        
        // Add prayer title and time
        shareText += "🕌 \(prayer.title) - \(prayer.subTitle) 🕌\n\n"
        
        // Add Arabic text if available
        if !prayer.arabic.isEmpty {
            shareText += "\(prayer.arabic)\n\n"
        }
        
        // Add reading if available
        if !prayer.reading.isEmpty {
            shareText += "Reading: \(prayer.reading)\n"
        }
        
        // Add meal if available
        if !prayer.meal.isEmpty {
            shareText += "Meal: \(prayer.meal)\n\n"
        }
        
        // Add footer
        shareText += "Shared from iSalah ☪️"
        
        return shareText
    }
    
    /// Shares text using the system share sheet
    /// - Parameter text: The text to share
    private func shareText(_ text: String) {
        // Get the active window scene and root view controller
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        // Create the activity view controller for sharing
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        // Present the share sheet
        rootViewController.present(activityViewController, animated: true)
    }
}

// MARK: - SwiftUI Extension

extension View {
    /// Adds a share button to any SwiftUI view
    /// - Parameter prayer: The prayer to share
    /// - Returns: View with share button
    func withPrayerShareButton(for prayer: TodayPrayerModel) -> some View {
        self.overlay(
            Button {
                PrayShareManager.shared.sharePrayer(prayer)
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
                    .padding(8)
                    .background(Circle().fill(Color.blue.opacity(0.1)))
            }
            .padding(8),
            alignment: .topTrailing
        )
    }
}

// MARK: - Example Usage

struct PrayerView_Example: View {
    let prayer: TodayPrayerModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(prayer.title)
                .font(.title)
            
            Text(prayer.subTitle)
                .font(.headline)
            
            if !prayer.arabic.isEmpty {
                Text(prayer.arabic)
                    .font(.body)
                    .padding(.top, 5)
            }
            
            if !prayer.reading.isEmpty {
                Text("Reading: \(prayer.reading)")
                    .font(.subheadline)
            }
            
            if !prayer.meal.isEmpty {
                Text("Meal: \(prayer.meal)")
                    .font(.subheadline)
            }
            
            // Share button at the bottom
            Button {
                PrayShareManager.shared.sharePrayer(prayer)
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.top, 10)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
        // Alternative: add share button to the entire card
        //.withPrayerShareButton(for: prayer)
    }
}
