//
//  ProfileViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import Foundation

class ProfileViewModel: ObservableObject {
    
    let coordinator: SettingsCoordinatorPresenter
    
    init(coordinator: SettingsCoordinatorPresenter) {
        self.coordinator = coordinator
    }
    
}

extension ProfileViewModel {
    
    func makeBackButton() {
        coordinator.navigate(to: .settings)
    }
    
}
