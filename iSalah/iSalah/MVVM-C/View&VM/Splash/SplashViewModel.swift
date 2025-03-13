//
//  SplashViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import Foundation
import Combine

class SplashViewModel: ObservableObject {
    
    @Published var isAppReady: Bool
    @Published var isAppUpdateRequired: Bool
    var cancelBag = Set<AnyCancellable>()
    
    init(isAppReady: Bool = false,
         isAppUpdateRequired: Bool = false) {
        self.isAppReady = isAppReady
        self.isAppUpdateRequired = isAppUpdateRequired
    }
    
}
//MARK: Firestore
extension SplashViewModel {
    
    func createUser(_ user: UserModel,resultId: @escaping (UserModel) -> Void) {
        FirebaseAuthManager.shared.authenticateAnonymously()
            .receive(on: DispatchQueue.main)
            .sink { value in
                switch value {
                case .finished:
                    print("SplashViewModel: Authenticated anonymously")
                case .failure(let error):
                    print( "SplashViewModel: Error authenticating anonymously \(error)" )
                }
                    
            } receiveValue: { [self] userId in
                print( "SplashViewModel: Authenticated anonymously with userId \(userId)" )
                FirebaseFirestoreManager.shared.saveHarvestData(user.harvest, userId: userId)
                
                DispatchQueue.main.async { [self] in
                    Task {
                        let model = await self.getAllUserInfo(userId)
                        
                        checkAppVersion(user.harvest.appVersion)
                        
                        resultId(model)
                    }
                }
            }
            .store(in: &cancelBag)
    }
    
    private func getAllUserInfo(_ userId: String) async -> UserModel {
        var model: UserModel = .init()
        
        model.location = await FirebaseFirestoreManager.shared.getSelectedLocation(userId: userId)
        model.appInfo = await FirebaseFirestoreManager.shared.getAppInfo(userId: userId)
        
        /// Info
        let premiumStatus = await RevenueCatManager.shared.checkSubscriptionStatus()
        model.info.isPremium = premiumStatus.hasSubscription
        model.info.premiumType = premiumStatus.premiumType
        
        return model
    }
    
    private func checkAppVersion(_ version: String) {
        let versionChecker = FirebaseSystemControllerManager.shared.checkAppVersion(currentVersion: version)
        
        versionChecker
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("SplashViewModel: Checking app version completed")
                case .failure(let error):
                    self.isAppReady = true
                    print("SplashViewModel: Checking app version failed: \(error) ")
                }
            } receiveValue: { [weak self] status in
                guard let self = self else { return }
                if status == .upToDate {
                    self.isAppReady = true
                } else {
                    self.isAppUpdateRequired = true
                }
            }
            .store(in: &cancelBag)

        
    }
    
}
