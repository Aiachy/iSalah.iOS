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
    var cancelBag = Set<AnyCancellable>()
    
    init(isAppReady: Bool = false) {
        self.isAppReady = isAppReady
    }
    
}

extension SplashViewModel {
    
    func createUser(_ user: UserModel,resultId: @escaping (UserModel) -> Void) {
        FirebaseAuthManager.shared.authenticateAnonymously()
            .receive(on: DispatchQueue.main)
            .sink { value in
                switch value {
                case .finished:
                    print("")
                case .failure(let error):
                    print(
                        "SplashViewModel: Error authenticating anonymously \(error)"
                    )
                }
                    
            } receiveValue: { [self] userId in
                print(
                    "SplashViewModel: Authenticated anonymously with userId \(userId)"
                )
                FirebaseFirestoreManager.shared.saveHarvestData(user.harvest, userId: userId)
                
                DispatchQueue.main.async {
                    Task {
                        let model = await self.getAllUserInfo(userId)
                        resultId(model)
                        self.isAppReady.toggle()
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
}
