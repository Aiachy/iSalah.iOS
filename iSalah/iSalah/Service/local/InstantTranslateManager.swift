import Foundation
import NaturalLanguage

class InstantTranslateManager {
    
    static let shared = InstantTranslateManager()
    
    private var translationCache: [String: [String: String]] = [:]
    private let cacheLock = NSLock()
    
    private let supportedLanguages = [
        "en", "ar", "tr", "ur", "fa", "id", "ms", "bn", "hi", "pa", "ps", "uz",
        "kk", "ky", "tg", "az", "tk", "ug", "tt", "fr", "sw", "ha", "so", "bm",
        "wo", "ru", "zh", "es", "de", "ku", "dv"
    ]
    
    private init() {}
    
    var deviceLanguage: String {
        let preferredLanguages = Locale.preferredLanguages
        let deviceLanguage = preferredLanguages.first ?? "en"
        let languageCode = deviceLanguage.split(separator: "-").first.map(String.init) ?? "en"
        return supportedLanguages.contains(languageCode) ? languageCode : "en"
    }
    
    func translate(_ text: String) -> String {
        guard !text.isEmpty else { return "" }
        
        let targetLanguage = deviceLanguage
        let sourceLanguage = detectLanguage(text)
        
        // Return original if languages are the same
        if sourceLanguage == targetLanguage {
            return text
        }
        
        // Check cache
        cacheLock.lock()
        if let cachedTranslations = translationCache[text],
           let translation = cachedTranslations[targetLanguage] {
            cacheLock.unlock()
            return translation
        }
        cacheLock.unlock()
        
        // Use real translation API or service here
        let translation = realTranslate(text, from: sourceLanguage, to: targetLanguage)
        
        // Cache the result
        cacheLock.lock()
        if translationCache[text] == nil {
            translationCache[text] = [:]
        }
        translationCache[text]?[targetLanguage] = translation
        cacheLock.unlock()
        
        return translation
    }
    
    private func detectLanguage(_ text: String) -> String {
        guard text.count > 5 else { return "en" }
        
        do {
            let recognizer = NLLanguageRecognizer()
            recognizer.processString(text)
            
            if let languageCode = recognizer.dominantLanguage?.rawValue {
                let code = languageCode.split(separator: "_").first.map(String.init) ?? "en"
                return supportedLanguages.contains(code) ? code : "en"
            }
            
            // Character-based detection fallbacks
            if text.contains("ö") || text.contains("ü") || text.contains("ç") || text.contains("ş") || text.contains("ğ") {
                return "tr"
            }
            
            if text.contains("ا") || text.contains("ب") || text.contains("ت") || text.contains("ث") {
                return "ar"
            }
        } catch {
            return "en"
        }
        
        return "en"
    }
    
    private func realTranslate(_ text: String, from sourceLanguage: String, to targetLanguage: String) -> String {
        // ÖNEMLİ: Bu kısımda gerçek çeviri API'sine bağlanabilirsiniz
        // Aşağıdaki örnekler sadece gösterim amaçlıdır
        
        // Örnek: Türkçe -> İngilizce çevirileri
        if sourceLanguage == "tr" && targetLanguage == "en" {
            if text.contains("Rabbimiz! Bizi Müslüman") {
                return "Our Lord! Make us Muslims submissive to Your will, and from our offspring a Muslim nation submissive to Your will; and show us our places for the celebration of our rites; and turn unto us in mercy; for You are the Oft-Returning, Most Merciful."
            }
        }
        
        // Örnek: İngilizce -> Türkçe çevirileri
        if sourceLanguage == "en" && targetLanguage == "tr" {
            if text.contains("Our Lord! Make us Muslims") {
                return "Rabbimiz! Bizi sana teslim olanlardan eyle ve soyumuzdan da sana teslim olacak bir ümmet çıkar, bize ibadet yerlerimizi göster ve tövbemizi kabul et. Şüphesiz sen tövbeleri çok kabul edensin, çok merhametlisin."
            }
        }
        
        // Gerçek uygulamada burada HTTP isteği yaparak çeviri API'sine bağlanabilirsiniz
        // Örnek:
        /*
        let apiKey = "YOUR_API_KEY"
        let urlString = "https://translation-api.example.com/translate?key=\(apiKey)&source=\(sourceLanguage)&target=\(targetLanguage)"
        guard let url = URL(string: urlString) else { return text }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(["text": text])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let semaphore = DispatchSemaphore(value: 0)
        var translatedText = text
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = try? JSONDecoder().decode(TranslationResponse.self, from: data) {
                translatedText = response.translatedText
            }
            semaphore.signal()
        }.resume()
        
        _ = semaphore.wait(timeout: .now() + 3.0)
        return translatedText
        */
        
        // TEST AMAÇLI: Gerçek API'ye bağlanmadığımız için, şimdilik orijinal metni döndürüyoruz
        return text
    }
}

// Kolay kullanım için String uzantısı
extension String {
    var translated: String {
        return InstantTranslateManager.shared.translate(self)
    }
}
