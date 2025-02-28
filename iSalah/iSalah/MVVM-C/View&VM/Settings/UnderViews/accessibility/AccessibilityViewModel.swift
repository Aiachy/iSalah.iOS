//
//  AccessibilityViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import Foundation

class AccessibilityViewModel: ObservableObject {
    
    @Published var isLocationSheetActive: Bool
    let coordinator: SettingsCoordinatorPresenter
    
    init(isLocationSheetActive: Bool = false,
         coordinator: SettingsCoordinatorPresenter) {
        self.isLocationSheetActive = isLocationSheetActive
        self.coordinator = coordinator
    }
}

extension AccessibilityViewModel {
    
    func makeBackButton() {
        coordinator.navigate(to: .settings)
    }
    
}
