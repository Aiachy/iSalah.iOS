//
//  AppVersionInfo.swift
//  iSalah
//
//  Created by Mert Türedü on 13.03.2025.
//


//
//  FirebaseSystemControllerManager.swift
//  iSalah
//
//  Created by Claude on 13.03.2025.
//

import Foundation
import FirebaseFirestore
import Combine


enum VersionStatus {
    case upToDate
    case updateAvailable
    case updateRequired
}

class FirebaseSystemControllerManager {
    // MARK: - Properties
    static let shared = FirebaseSystemControllerManager()
    private let db = Firestore.firestore()
    private let backgroundQueue = DispatchQueue(label: "com.isalah.firebaseSystem", qos: .background)
    

    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - App Version Methods
    func checkAppVersion(currentVersion: String) -> AnyPublisher<(VersionStatus), Error> {
        return Future<VersionStatus, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FirebaseSystemControllerManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Manager has been deallocated"])))
                return
            }
            
            let docRef = self.db.collection(CollectionPath.system).document(CollectionPath.appInfo)
            
            docRef.getDocument { (document, error) in
                if let error = error {
                    print("FirebaseSystemControllerManager: checkAppVersion ❌ Error fetching version info: \(error.localizedDescription)")
                    promise(.failure(error))
                    return
                }
                
                guard let document = document, document.exists else {
                    print("FirebaseSystemControllerManager: checkAppVersion ⚠️ AppInfo document not found.")
                    return
                }
                
                guard let data = document.data() else {
                    print("FirebaseSystemControllerManager: checkAppVersion ⚠️ AppInfo data is empty.")

                    return
                }
                
                // Parse version data
                let minimumVersion = data["minimumVersion"] as? String ?? "0.32"
                let latestVersion = data["latestVersion"] as? String ?? "0.32"
                let versionInfo = ""
                
                print("FirebaseSystemControllerManager: checkAppVersion ✅ Fetched version info - Current: \(currentVersion), Minimum: \(minimumVersion), Latest: \(latestVersion)")
                
                // Compare versions
                if self.compareVersions(currentVersion, minimumVersion) == .orderedAscending {
                    // Current version is less than minimum required version
                    print("FirebaseSystemControllerManager: checkAppVersion 🚨 Update required")
                    promise(.success((.updateRequired)))
                } else if self.compareVersions(currentVersion, latestVersion) == .orderedAscending {
                    // Current version is less than latest version but greater than or equal to minimum
                    print("FirebaseSystemControllerManager: checkAppVersion ⚠️ Update available")
                    promise(.success((.updateAvailable)))
                } else {
                    // Current version is up to date
                    print("FirebaseSystemControllerManager: checkAppVersion ✅ App is up to date")
                    promise(.success((.upToDate)))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // Compare version strings (e.g., "1.2.3" vs "1.3.0")
    private func compareVersions(_ version1: String, _ version2: String) -> ComparisonResult {
        return version1.compare(version2, options: .numeric)
    }
}
