//
//  ThemeViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import Foundation

class ThemeViewModel: ObservableObject {
    
    let coordinator: SettingsCoordinatorPresenter
    
    init(coordinator: SettingsCoordinatorPresenter) {
        self.coordinator = coordinator
    }
    
}

extension ThemeViewModel {
    func makeBackButton() {
        coordinator.navigate(to: .settings)
    }
}
