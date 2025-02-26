//
//  SplashViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import Foundation

class SplashViewModel: ObservableObject {
    
    @Published var isAppReady: Bool
    
    init(isAppReady: Bool = false) {
        self.isAppReady = isAppReady
        
        simulateAppReady()
    }
    
}

private extension SplashViewModel {
    
    func simulateAppReady() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isAppReady = true
        }
    }
}
