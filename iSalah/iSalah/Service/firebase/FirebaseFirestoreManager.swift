import Foundation
import FirebaseFirestore
import FirebaseAuth
import CoreLocation

class FirebaseFirestoreManager {
    // MARK: - Properties
    static let shared = FirebaseFirestoreManager()
    private let db = Firestore.firestore()
    private let backgroundQueue = DispatchQueue(label: "com.isalah.firebaseFirestore", qos: .background)
    
    // MARK: - Constants
    private struct CollectionPath {
        static let users = "users"
        static let core = "Core"
        static let harvest = "Harvest"
        static let appInfo = "AppInfo"
    }
    
    // MARK: - Initialization
    private init() {
        let settings = FirestoreSettings()
        db.settings = settings
    }
    
    // MARK: - Helper Methods
    private func getCurrentUserId() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    private func getDocumentReference(userId: String, collection: String, document: String) -> DocumentReference {
        return db.collection(CollectionPath.users)
            .document(userId)
            .collection(collection)
            .document(document)
    }
    
    private func convertToFirestoreData<T: Encodable>(_ data: T) -> [String: Any] {
        do {
            let encoder = JSONEncoder()
            let jsonData = try encoder.encode(data)
            
            if let dict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                return dict
            }
        } catch {
            print("FirebaseFirestoreManager: convertToFirestoreData 🔴 Data conversion failed! \(error.localizedDescription)")
        }
        
        return [:]
    }
    
    // MARK: - Safe Data Conversion Methods
    
    // NSNumber ve Int64/UInt64 için güvenli dönüşüm
    private func safeValueForFirestore(_ value: Any) -> Any {
        if value is NSNumber {
            return value
        } else if value is Int64 || value is UInt64 {
            return "\(value)" // String'e dönüştür
        } else if value is TimeInterval {
            return "\(value)" // String'e dönüştür
        } else if let dict = value as? [String: Any] {
            return safeDataForFirestore(dict)
        } else if let array = value as? [Any] {
            return safeArrayForFirestore(array)
        } else {
            return value
        }
    }
    
    // Dictionary'leri güvenli hale getirme
    private func safeDataForFirestore(_ data: [String: Any]) -> [String: Any] {
        var result: [String: Any] = [:]
        
        for (key, value) in data {
            result[key] = safeValueForFirestore(value)
        }
        
        return result
    }
    
    // Array'leri güvenli hale getirme
    private func safeArrayForFirestore(_ array: [Any]) -> [Any] {
        return array.map { safeValueForFirestore($0) }
    }
    
    func listenToAppInfoChanges(userId: String? = nil, listener: @escaping (AppInfoModel?, Error?) -> Void) -> (() -> Void) {
        let uid = userId ?? getCurrentUserId() ?? ""
        
        guard !uid.isEmpty else {
            DispatchQueue.main.async {
                print("FirebaseFirestoreManager: listenToAppInfoChanges ⚠️ User ID not found! Unable to create AppInfo listener.")
                listener(nil, NSError(domain: "FirebaseFirestoreManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "User ID not found"]))
            }
            return {}
        }
        
        let docRef = getDocumentReference(userId: uid, collection: CollectionPath.core, document: CollectionPath.appInfo)
        
        print("FirebaseFirestoreManager: listenToAppInfoChanges 👂 Listening for AppInfo changes... [User: \(uid)]")
        
        let listenerRegistration = docRef.addSnapshotListener { [weak self] (documentSnapshot, error) in
            guard self != nil else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    print("FirebaseFirestoreManager: listenToAppInfoChanges ❌ AppInfo listener error: \(error.localizedDescription)")
                    listener(nil, error)
                    return
                }
                
                guard let document = documentSnapshot, document.exists else {
                    print("FirebaseFirestoreManager: listenToAppInfoChanges ℹ️ AppInfo data not found. Continuing with default values. [User: \(uid)]")
                    listener(AppInfoModel(), nil)
                    return
                }
                
                do {
                    if let documentData = document.data() {
                        let jsonData = try JSONSerialization.data(withJSONObject: documentData)
                        let decoder = JSONDecoder()
                        let appInfo = try decoder.decode(AppInfoModel.self, from: jsonData)
                        print("FirebaseFirestoreManager: listenToAppInfoChanges 🔔 AppInfo change detected! [User: \(uid), Theme: \(appInfo.theme)]")
                        listener(appInfo, nil)
                    } else {
                        print("FirebaseFirestoreManager: listenToAppInfoChanges ℹ️ AppInfo change detected but data is empty. Continuing with default values. [User: \(uid)]")
                        listener(AppInfoModel(), nil)
                    }
                } catch {
                    print("FirebaseFirestoreManager: listenToAppInfoChanges ❌ Failed to decode AppInfo change: \(error.localizedDescription)")
                    listener(nil, error)
                }
            }
        }
        
        return {
            print("FirebaseFirestoreManager: listenToAppInfoChanges 🛑 AppInfo listener stopped. [User: \(uid)]")
            listenerRegistration.remove()
        }
    }
    
    // MARK: - Batch Operations
    func saveBatchData(harvest: HarvestModel? = nil, appInfo: AppInfoModel? = nil, userId: String? = nil, completion: @escaping (Bool, Error?) -> Void) {
        // Arka planda işlem yap
        backgroundQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(false, NSError(domain: "FirebaseFirestoreManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Manager has been deallocated"]))
                }
                return
            }
            
            let uid = userId ?? self.getCurrentUserId() ?? ""
            
            guard !uid.isEmpty else {
                DispatchQueue.main.async {
                    print("FirebaseFirestoreManager: saveBatchData ⚠️ User ID not found! Unable to save batch data.")
                    completion(false, NSError(domain: "FirebaseFirestoreManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "User ID not found"]))
                }
                return
            }
            
            let batch = self.db.batch()
            let timestamp = FieldValue.serverTimestamp()
            
            DispatchQueue.main.async {
                print("FirebaseFirestoreManager: saveBatchData 🔄 Starting batch operation... [User: \(uid)]")
            }
            
            if let harvest = harvest {
                let harvestRef = self.getDocumentReference(userId: uid, collection: CollectionPath.core, document: CollectionPath.harvest)
                var harvestDict = harvest.toJSON()
                
                // usageByHour'ı düzelt (Int -> String anahtarına dönüştür)
                if let usageByHour = harvestDict["usageByHour"] as? [Int: TimeInterval] {
                    var fixedUsageByHour: [String: String] = [:]
                    for (hour, duration) in usageByHour {
                        fixedUsageByHour["\(hour)"] = "\(duration)"
                    }
                    harvestDict["usageByHour"] = fixedUsageByHour
                }
                
                let safeHarvestData = self.safeDataForFirestore(harvestDict)
                var harvestDataToSave = safeHarvestData
                harvestDataToSave["lastUpdated"] = timestamp
                
                batch.setData(harvestDataToSave, forDocument: harvestRef, merge: true)
                
                DispatchQueue.main.async {
                    print("FirebaseFirestoreManager: saveBatchData 📦 Added Harvest data to batch. [User: \(uid)]")
                }
            }
            
            if let appInfo = appInfo {
                let appInfoRef = self.getDocumentReference(userId: uid, collection: CollectionPath.core, document: CollectionPath.appInfo)
                var appInfoDict = self.convertToFirestoreData(appInfo)
                appInfoDict["lastUpdated"] = timestamp
                batch.setData(appInfoDict, forDocument: appInfoRef, merge: true)
                
                DispatchQueue.main.async {
                    print("FirebaseFirestoreManager: saveBatchData 📦 Added AppInfo data to batch. [User: \(uid), Theme: \(appInfo.theme)]")
                }
            }
            
            batch.commit { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("FirebaseFirestoreManager: saveBatchData ❌ Batch operation failed: \(error.localizedDescription)")
                        completion(false, error)
                    } else {
                        print("FirebaseFirestoreManager: saveBatchData ✅ Batch operation completed successfully! [User: \(uid)]")
                        completion(true, nil)
                    }
                }
            }
        }
    }
}
//MARK: Harvest
extension FirebaseFirestoreManager {
    // MARK: - Harvest Methods
    func saveHarvestData(_ harvestData: HarvestModel, userId: String? = nil) {
        // Arka planda işlem yap
        backgroundQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    print("FirebaseFirestoreManager: saveHarvestData ❌ Self has been deallocated")
                }
                return
            }
            
            let uid = userId ?? self.getCurrentUserId() ?? ""
            
            guard !uid.isEmpty else {
                DispatchQueue.main.async {
                    print("FirebaseFirestoreManager: saveHarvestData ⚠️ User ID not found! Unable to save Harvest data.")
                }
                return
            }
            
            let docRef = self.getDocumentReference(userId: uid, collection: CollectionPath.core, document: CollectionPath.harvest)
            
            do {
                // Veriyi güvenli bir şekilde dönüştür
                var harvestDict = harvestData.toJSON()
                
                // usageByHour'ı düzelt (Int -> String anahtarına dönüştür)
                if let usageByHour = harvestDict["usageByHour"] as? [Int: TimeInterval] {
                    var fixedUsageByHour: [String: String] = [:]
                    for (hour, duration) in usageByHour {
                        fixedUsageByHour["\(hour)"] = "\(duration)"
                    }
                    harvestDict["usageByHour"] = fixedUsageByHour
                }
                
                // Diğer sayısal değerleri güvenli hale getir
                let safeData = self.safeDataForFirestore(harvestDict)
                var dataToSave = safeData
                dataToSave["lastUpdated"] = FieldValue.serverTimestamp()
                
                DispatchQueue.main.async {
                    print("FirebaseFirestoreManager: saveHarvestData 🔄 Saving Harvest data to Firestore... [User: \(uid)]")
                }
                
                docRef.setData(dataToSave, merge: true) { error in
                    DispatchQueue.main.async {
                        if let error = error {
                            print("FirebaseFirestoreManager: saveHarvestData ❌ Failed to save Harvest data: \(error.localizedDescription)")
                        } else {
                            print("FirebaseFirestoreManager: saveHarvestData ✅ Successfully saved Harvest data to Firestore! [User: \(uid)]")
                        }
                    }
                }
            } catch {
                print("FirebaseFirestoreManager: saveHarvestData ❌ Error preparing Harvest data: \(error.localizedDescription)")
            }
        }
    }
    
    func getHarvestData(userId: String? = nil) async -> HarvestModel {
        let uid = userId ?? getCurrentUserId() ?? ""
        
        guard !uid.isEmpty else {
            print("FirebaseFirestoreManager: getHarvestData ⚠️ User ID not found! Unable to fetch Harvest data.")
            return HarvestModel()
        }
        
        let docRef = getDocumentReference(userId: uid, collection: CollectionPath.core, document: CollectionPath.harvest)
        
        print("FirebaseFirestoreManager: getHarvestData 🔄 Fetching Harvest data from Firestore... [User: \(uid)]")
        
        do {
            let document = try await docRef.getDocument()
            
            guard document.exists, document.data() != nil else {
                print("FirebaseFirestoreManager: getHarvestData ⚠️ Harvest data not found. [User: \(uid)]")
                return HarvestModel()
            }
            
            print("FirebaseFirestoreManager: getHarvestData ✅ Successfully fetched Harvest data! [User: \(uid)]")
            return HarvestModel()
        } catch {
            print("FirebaseFirestoreManager: getHarvestData ❌ Failed to fetch Harvest data: \(error.localizedDescription)")
            return HarvestModel()
        }
    }
    
}
//MARK: AppInfo
extension FirebaseFirestoreManager {
    // MARK: - AppInfo Methods
    func saveAppInfo(_ appInfo: AppInfoModel, userId: String? = nil) {
        // Arka planda işlem yap
        backgroundQueue.async { [weak self] in
            guard let self = self else {
                print("FirebaseFirestoreManager: saveAppInfo ⚠️ Self weak reference nil!")
                return
            }
            
            let uid = userId ?? self.getCurrentUserId() ?? ""
            
            guard !uid.isEmpty else {
                    print("FirebaseFirestoreManager: saveAppInfo ⚠️ User ID not found! Unable to save AppInfo data.")
                return
            }
            
            let docRef = self.getDocumentReference(userId: uid, collection: CollectionPath.core, document: CollectionPath.appInfo)
            
            let appInfoDict = self.convertToFirestoreData(appInfo)
            var dataToSave: [String: Any] = appInfoDict
            dataToSave["lastUpdated"] = FieldValue.serverTimestamp()
            
            DispatchQueue.main.async {
                print("FirebaseFirestoreManager: saveAppInfo 🔄 Saving AppInfo data to Firestore... [User: \(uid), Theme: \(appInfo.theme)]")
            }
            
            docRef.setData(dataToSave, merge: true) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("FirebaseFirestoreManager: saveAppInfo ❌ Failed to save AppInfo data: \(error.localizedDescription)")
                    } else {
                        print("FirebaseFirestoreManager: saveAppInfo ✅ Successfully saved AppInfo data to Firestore! [User: \(uid), Theme: \(appInfo.theme)]")
                    }
                }
            }
        }
    }
    
    func getAppInfo(userId: String? = nil) async -> AppInfoModel {
        let uid = userId ?? self.getCurrentUserId() ?? ""
        
        guard !uid.isEmpty else {
            print("FirebaseFirestoreManager: getAppInfo ⚠️ User ID not found! Unable to fetch AppInfo data.")
            return AppInfoModel()
        }
        
        let docRef = self.getDocumentReference(userId: uid, collection: CollectionPath.core, document: CollectionPath.appInfo)
        
        print("FirebaseFirestoreManager: getAppInfo 🔄 Fetching AppInfo data from Firestore... [User: \(uid)]")
        
        do {
            let document = try await docRef.getDocument()
            
            guard document.exists else {
                print("FirebaseFirestoreManager: getAppInfo ℹ️ AppInfo data not found. Using default values. [User: \(uid)]")
                return AppInfoModel()
            }
            
            guard var documentData = document.data() else {
                print("FirebaseFirestoreManager: getAppInfo ℹ️ AppInfo data is empty. Using default values. [User: \(uid)]")
                return AppInfoModel()
            }
            
            if documentData["lastUpdated"] is Timestamp {
                documentData.removeValue(forKey: "lastUpdated")
            }
            
            if let theme = documentData["theme"] as? String {
                let appInfo = AppInfoModel(theme: theme)
                print("FirebaseFirestoreManager: getAppInfo ✅ Successfully fetched AppInfo data! [User: \(uid), Theme: \(appInfo.theme)]")
                return appInfo
            }
            
            print("FirebaseFirestoreManager: getAppInfo ⚠️ Invalid or missing theme data. Using default values. [User: \(uid)]")
            return AppInfoModel()
        } catch {
            print("FirebaseFirestoreManager: getAppInfo ❌ Failed to fetch/decode AppInfo data: \(error.localizedDescription)")
            return AppInfoModel()
        }
    }
}

extension FirebaseFirestoreManager {
    
    // MARK: - Constants
    private struct LocationPaths {
        static let locationDocument = "Location"
        static let suggestionsField = "suggestions"
        static let selectedLocationField = "selectedLocation"
    }
    
    // MARK: - Save Methods
    func saveLocationSuggestion(_ location: LocationSuggestion, userId: String? = nil) {
        // Arka planda işlem yap
        backgroundQueue.async { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    print("FirebaseFirestoreManager: saveLocationSuggestion ❌ Self has been deallocated")
                }
                return
            }
            
            let uid = userId ?? self.getCurrentUserId() ?? ""
            
            guard !uid.isEmpty else {
                DispatchQueue.main.async {
                    print("FirebaseFirestoreManager: saveLocationSuggestion ⚠️ User ID not found! Unable to save location data.")
                }
                return
            }
            
            let docRef = self.getDocumentReference(userId: uid, collection: CollectionPath.core, document: LocationPaths.locationDocument)
            
            // LocationSuggestion'ı Firestore'a uyumlu formata dönüştür
            let locationData: [String: Any] = [
                "country": location.country,
                "city": location.city,
                "district": location.district,
                "formattedLocation": location.formattedLocation,
                "coordinate": [
                    "latitude": location.coordinate.latitude,
                    "longitude": location.coordinate.longitude
                ]
            ]
            
            // Güvenli veriyi hazırla
            let safeData = self.safeDataForFirestore(locationData)
            
            // Seçilen konum alanını güncelle
            let dataToSave: [String: Any] = [
                LocationPaths.selectedLocationField: safeData,
                "lastUpdated": FieldValue.serverTimestamp()
            ]
            
            DispatchQueue.main.async {
                print("FirebaseFirestoreManager: saveLocationSuggestion 🔄 Saving location data to Firestore... [User: \(uid), Location: \(location.formattedLocation)]")
            }
            
            docRef.setData(dataToSave, merge: true) { error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("FirebaseFirestoreManager: saveLocationSuggestion ❌ Failed to save location data: \(error.localizedDescription)")
                    } else {
                        print("FirebaseFirestoreManager: saveLocationSuggestion ✅ Successfully saved location data to Firestore! [User: \(uid), Location: \(location.formattedLocation)]")
                    }
                }
            }
        }
    }
    
    func getSelectedLocation(userId: String? = nil) async -> LocationSuggestion? {
        let uid = userId ?? getCurrentUserId() ?? ""
        
        guard !uid.isEmpty else {
            print("FirebaseFirestoreManager: getSelectedLocation ⚠️ User ID not found! Unable to fetch selected location.")
            return nil
        }
        
        let docRef = getDocumentReference(userId: uid, collection: CollectionPath.core, document: LocationPaths.locationDocument)
        
        print("FirebaseFirestoreManager: getSelectedLocation 🔄 Fetching selected location from Firestore... [User: \(uid)]")
        
        do {
            let document = try await docRef.getDocument()
            
            guard document.exists else {
                print("FirebaseFirestoreManager: getSelectedLocation ℹ️ No location document found. [User: \(uid)]")
                return nil
            }
            
            guard let selectedLocationData = document.data()?[LocationPaths.selectedLocationField] as? [String: Any] else {
                print("FirebaseFirestoreManager: getSelectedLocation ℹ️ Selected location field not found. [User: \(uid)]")
                return nil
            }
            
            // LocationSuggestion nesnesine dönüştür
            if let country = selectedLocationData["country"] as? String,
               let city = selectedLocationData["city"] as? String,
               let district = selectedLocationData["district"] as? String,
               let coordinateData = selectedLocationData["coordinate"] as? [String: Any],
               let latitude = coordinateData["latitude"] as? Double,
               let longitude = coordinateData["longitude"] as? Double {
                
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let selectedLocation = LocationSuggestion(country: country, city: city, district: district, coordinate: coordinate)
                
                print("FirebaseFirestoreManager: getSelectedLocation ✅ Successfully fetched selected location! [User: \(uid), Location: \(selectedLocation.formattedLocation)]")
                return selectedLocation
            } else {
                print("FirebaseFirestoreManager: getSelectedLocation ❌ Failed to parse selected location data. [User: \(uid)]")
                return nil
            }
        } catch {
            print("FirebaseFirestoreManager: getSelectedLocation ❌ Failed to fetch selected location: \(error.localizedDescription)")
            return nil
        }
    }
}
