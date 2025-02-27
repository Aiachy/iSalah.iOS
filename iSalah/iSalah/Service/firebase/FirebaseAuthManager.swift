//
//  FirebaseAuthManager.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseFirestore
import Combine

// Singleton FirebaseAuthManager - no ObservableObject
final class FirebaseAuthManager {
    // Singleton instance
    static let shared = FirebaseAuthManager()
    
    // User authentication state properties (not published)
    private(set) var isAuthenticated: Bool = false
    private(set) var userID: String?
    
    // Firestore reference
    private let db = Firestore.firestore()
        
    // Cancellables set for Combine
    var cancellables = Set<AnyCancellable>()
    
    // Private initializer for singleton pattern
    private init() {
        // Check if user is already authenticated (stored in UserDefaults)
        checkExistingAuth()
    }
    
    private func checkExistingAuth() {
        // Try to get stored userID from UserDefaults
        if let storedUserID = UserDefaults.standard.string(forKey: userIDKey) {
            self.userID = storedUserID
            self.isAuthenticated = true
            
            // Check if user exists in Firestore
            validateFirestoreUser(userID: storedUserID)
        }
    }
    
    // Authenticate anonymously and set up user
    func authenticateAnonymously() -> AnyPublisher<String, Error> {
        return Future<String, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FirebaseAuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }
            
            // First check if we already have a user ID
            if let existingUserID = self.userID {
                promise(.success(existingUserID))
                return
            }
            
            // Otherwise authenticate anonymously
            Auth.auth().signInAnonymously { authResult, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                guard let user = authResult?.user else {
                    promise(.failure(NSError(domain: "FirebaseAuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get user after authentication"])))
                    return
                }
                
                let userID = user.uid
                
                // Store in UserDefaults
                UserDefaults.standard.set(userID, forKey: userIDKey)
                
                // Update properties
                self.userID = userID
                self.isAuthenticated = true
                
                // Create user document in Firestore
                self.createUserInFirestore(userID: userID)
                    .sink(receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            // Just log error but don't fail the whole auth process
                            print("Failed to create user in Firestore: \(error.localizedDescription)")
                        }
                        promise(.success(userID))
                    }, receiveValue: { _ in
                        promise(.success(userID))
                    })
                    .store(in: &self.cancellables)
            }
        }.eraseToAnyPublisher()
    }
    
    // Create user document in Firestore with ID as document ID
    private func createUserInFirestore(userID: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FirebaseAuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }
            
            // Check if user document already exists
            self.db.collection("users").document(userID).getDocument { document, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                // If document exists, no need to create it again
                if let document = document, document.exists {
                    promise(.success(()))
                    return
                }
                
                // Create new user document
                let userData: [String: Any] = [
                    "id": userID,
                    "createdAt": FieldValue.serverTimestamp(),
                    "lastLogin": FieldValue.serverTimestamp()
                ]
                
                self.db.collection("users").document(userID).setData(userData) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // Validate that user exists in Firestore and update last login time
    private func validateFirestoreUser(userID: String) {
        db.collection("users").document(userID).getDocument { [weak self] document, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error checking user document: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                // Update last login time
                self.db.collection("users").document(userID).updateData([
                    "lastLogin": FieldValue.serverTimestamp()
                ])
            } else {
                // Create user document if it doesn't exist
                self.createUserInFirestore(userID: userID)
                    .sink(receiveCompletion: { completion in
                        if case let .failure(error) = completion {
                            print("Failed to create user in Firestore: \(error.localizedDescription)")
                        }
                    }, receiveValue: { _ in })
                    .store(in: &self.cancellables)
            }
        }
    }
    
    // Sign out current user
    func signOut() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "FirebaseAuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }
            
            do {
                try Auth.auth().signOut()
                
                // Clear UserDefaults
                UserDefaults.standard.removeObject(forKey: userIDKey)
                
                // Update properties
                self.userID = nil
                self.isAuthenticated = false
                
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
