//
//  iSalahState.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import Foundation
import Combine

class iSalahState: ObservableObject {
    
    @Published var user: UserModel
    var cancelBag = Set<AnyCancellable>()
    
    init(user: UserModel = .init()) {
        self.user = user
        
        allListeners()
    }
    
}


//MARK: Handlers
private extension iSalahState {
    
    private func allListeners() {
        let userId = user.wrappedId
     
        $user
            .map(\.appInfo)
            .receive(on: DispatchQueue.main)
            .sink {  appInfo in
                print("iSalahState: AppInfo değişikliği algılandı, Firestore'a kaydediliyor... [Theme: \(appInfo.theme)]")
                FirebaseFirestoreManager.shared.saveAppInfo(appInfo, userId: userId)
            }
            .store(in: &cancelBag)
        
        $user
            .map(\.location)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { location in
                if let location = location {
                    print("iSalahState: Location değişikliği algılandı, Firestore'a kaydediliyor... [Location: \(location.formattedLocation)]")
                    
                    FirebaseFirestoreManager.shared.saveLocationSuggestion(location, userId: userId)
                }
            }
            .store(in: &cancelBag)
    }
}
