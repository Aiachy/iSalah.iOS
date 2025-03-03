//
//  PrayerTranslationManager.swift
//  iSalah
//
//  Created by Mert Türedü on 03.03.2025.
//

import Foundation
import SwiftUI
import NaturalLanguage

/// Translation manager for prayer content using Apple's translation capabilities
@MainActor
class PrayerTranslationManager: ObservableObject {
    /// Shared instance for easy access throughout the app
    static let shared = PrayerTranslationManager()
    
    // Language detection
    private let tagger = NLTagger(tagSchemes: [.language])
    
    /// Indicates if the manager has been initialized
    @Published var isInitialized = false
    
    /// Translation cache for performance optimization
    private var translationCache = [String: [String: String]]() // [sourceText: [targetLanguage: translatedText]]
    
    private init() {
        Task {
            await initialize()
        }
    }
    
    /// Initialize the translation manager
    private func initialize() async {
        isInitialized = true
        print("Translation manager initialized")
    }
    
    /// Translates text to the specified language
    /// - Parameters:
    ///   - text: The text to translate
    ///   - targetLanguageCode: ISO language code (e.g., "en", "tr", "fr")
    /// - Returns: Translated text or original text if translation fails
    func translate(text: String, to targetLanguageCode: String? = nil) async -> String {
        // Check if text is empty
        guard !text.isEmpty else { return text }
        
        // Use device language if target language is nil
        let deviceLanguageCode = Locale.current.languageCode ?? "en"
        let targetCode = targetLanguageCode ?? deviceLanguageCode
        
        // Check cache first to improve performance
        if let cachedTranslations = translationCache[text],
           let cachedTranslation = cachedTranslations[targetCode] {
            return cachedTranslation
        }
        
        // Detect source language
        let detectedLanguageCode = detectLanguage(for: text)
        
        // If source and target languages are the same, return original
        if detectedLanguageCode == targetCode {
            return text
        }
        
        // Perform translation
        let translatedText = await performTranslation(text: text,
                                                    sourceLanguage: detectedLanguageCode,
                                                    targetLanguage: targetCode)
        
        // Cache the result
        if translationCache[text] == nil {
            translationCache[text] = [:]
        }
        translationCache[text]?[targetCode] = translatedText
        
        return translatedText
    }
    
    /// Detect the language of a text
    /// - Parameter text: Text to analyze
    /// - Returns: Language code or "en" if detection fails
    private func detectLanguage(for text: String) -> String {
        tagger.string = text
        let language = tagger.dominantLanguage?.rawValue ?? "en"
        return language
    }
    
    /// Performs the actual translation using iOS translation capabilities
    /// - Parameters:
    ///   - text: Text to translate
    ///   - sourceLanguage: Source language code
    ///   - targetLanguage: Target language code
    /// - Returns: Translated text or original if translation fails
    private func performTranslation(text: String, sourceLanguage: String, targetLanguage: String) async -> String {
        // Platform-specific implementation for iOS 15+
        #if os(iOS)
        if #available(iOS 15.0, *) {
            // Here you would integrate with Apple's built-in translation services
            // iOS 15+ supports on-device translation through Apple's Private Framework
            
            do {
                // In a real implementation, you would use Apple's private API here
                // Or a properly configured third-party service
                
                // For demo/testing purposes, we'll use our own "translation" service
                return simulateTranslation(text: text, from: sourceLanguage, to: targetLanguage)
            } catch {
                print("Translation error: \(error.localizedDescription)")
                return text
            }
        }
        #endif
        
        // Fallback for older iOS versions or when translation fails
        return simulateTranslation(text: text, from: sourceLanguage, to: targetLanguage)
    }
    
    /// Simulates translation for testing/demo purposes
    /// In a real app, replace this with actual translation API calls
    private func simulateTranslation(text: String, from sourceLanguage: String, to targetLanguage: String) -> String {
        // For demo purposes, we'll recognize a few common words
        // This is just to demonstrate the functionality - in a real app, you would use a translation API
        
        // Simple word dictionary for certain languages
        let translationDict: [String: [String: [String: String]]] = [
            "en": [
                "tr": [
                    "Hello": "Merhaba",
                    "Prayer": "Dua",
                    "God": "Allah",
                    "Mercy": "Rahmet",
                    "Peace": "Barış",
                    "Faith": "İman",
                    "Lord": "Rab",
                    "Prophet": "Peygamber",
                    "Blessing": "Bereket"
                ],
                "ar": [
                    "Hello": "السلام عليكم",
                    "Prayer": "صلاة",
                    "God": "الله",
                    "Mercy": "رحمة",
                    "Peace": "سلام",
                    "Faith": "إيمان",
                    "Lord": "رب",
                    "Prophet": "نبي",
                    "Blessing": "بركة"
                ],
                "fr": [
                    "Hello": "Bonjour",
                    "Prayer": "Prière",
                    "God": "Dieu",
                    "Mercy": "Miséricorde",
                    "Peace": "Paix",
                    "Faith": "Foi",
                    "Lord": "Seigneur",
                    "Prophet": "Prophète",
                    "Blessing": "Bénédiction"
                ]
            ]
        ]
        
        // If we don't have translation for this language pair, return original
        guard let sourceLangDict = translationDict[sourceLanguage],
              let targetLangDict = sourceLangDict[targetLanguage] else {
            return text
        }
        
        // Simple word replacement (very naive translation)
        var translatedText = text
        for (originalWord, translatedWord) in targetLangDict {
            translatedText = translatedText.replacingOccurrences(
                of: "\\b\(originalWord)\\b",
                with: translatedWord,
                options: [.regularExpression, .caseInsensitive]
            )
        }
        
        return translatedText
    }
    
    /// Translates the meal portion of a prayer model
    /// - Parameters:
    ///   - prayer: The prayer model to translate
    ///   - languageCode: Target language code
    /// - Returns: New prayer model with translated meal
    func translatePrayer(_ prayer: TodayPrayerModel, to languageCode: String? = nil) async -> TodayPrayerModel {
        let translatedMeal = await translate(text: prayer.meal, to: languageCode)
        
        return TodayPrayerModel(
            id: prayer.id,
            title: prayer.title,
            subTitle: prayer.subTitle,
            arabic: prayer.arabic,
            reading: prayer.reading,
            meal: translatedMeal
        )
    }
    
    /// Translates an array of prayers
    /// - Parameters:
    ///   - prayers: Array of prayer models
    ///   - languageCode: Target language code
    /// - Returns: Array of translated prayer models
    func translatePrayers(_ prayers: [TodayPrayerModel], to languageCode: String? = nil) async -> [TodayPrayerModel] {
        var translatedPrayers = [TodayPrayerModel]()
        
        for prayer in prayers {
            let translatedPrayer = await translatePrayer(prayer, to: languageCode)
            translatedPrayers.append(translatedPrayer)
        }
        
        return translatedPrayers
    }
    
    /// Get list of available language codes
    func availableLanguageCodes() -> [String] {
        // Return commonly supported languages
        return [
            "en", "fr", "de", "es", "it", "ja", "ko", "pt",
            "ru", "zh", "ar", "tr", "hi", "th", "vi", "id",
            "nl", "pl"
        ]
    }
    
    /// Clears the translation cache
    func clearCache() {
        translationCache.removeAll()
    }
}
