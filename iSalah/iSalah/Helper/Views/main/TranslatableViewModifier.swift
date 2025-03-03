//
//  TranslatableViewModifier.swift
//  iSalah
//
//  Created by Mert Türedü on 3.03.2025.
//


//
//  TodayPrayView+Translation.swift
//  iSalah
//
//  Created by Mert Türedü on 03.03.2025.
//

import SwiftUI

// Extension for TodayPrayView to add translation functionality
extension TodayPrayView {
    
    /// Get a translated version of the prayer model
    /// - Parameter languageCode: The target language code (e.g., "en", "tr", "fr")
    /// - Returns: An async task that yields the translated prayer model
    func translatedPrayer(to languageCode: String? = nil) async -> TodayPrayerModel {
        return await PrayerTranslationManager.shared.translatePrayer(model, to: languageCode)
    }
    
    /// Create a view modifier that enables language selection
    struct TranslatableViewModifier: ViewModifier {
        let originalModel: TodayPrayerModel
        @State private var translatedModel: TodayPrayerModel
        @State private var currentLanguage: String
        @State private var isTranslating = false
        
        init(model: TodayPrayerModel, language: String? = nil) {
            self.originalModel = model
            self._translatedModel = State(initialValue: model)
            self._currentLanguage = State(initialValue: language ?? Locale.current.languageCode ?? "en")
        }
        
        func body(content: Content) -> some View {
            content
                .task {
                    await translateModel()
                }
                .onChange(of: currentLanguage) { _, _ in
                    Task {
                        await translateModel()
                    }
                }
                .overlay {
                    if isTranslating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                }
        }
        
        private func translateModel() async {
            isTranslating = true
            translatedModel = await PrayerTranslationManager.shared.translatePrayer(originalModel, to: currentLanguage)
            isTranslating = false
        }
    }
}

// Extension to make it easier to use the translatable modifier
extension View {
    func translatable(model: TodayPrayerModel, language: String? = nil) -> some View {
        self.modifier(TodayPrayView.TranslatableViewModifier(model: model, language: language))
    }
}