//
//  ThemeViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import Foundation

class ThemeViewModel: ObservableObject {
    
    @Published var isPaywallAppear: Bool
    let coordinator: SettingsCoordinatorPresenter
    
    init(
        isPaywallAppear: Bool = false,
        coordinator: SettingsCoordinatorPresenter
    ) {
        self.isPaywallAppear = isPaywallAppear
        self.coordinator = coordinator
    }
    
}

extension ThemeViewModel {
    func makeBackButton() {
        coordinator.navigate(to: .settings)
    }
}
