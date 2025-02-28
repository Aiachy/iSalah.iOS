//
//  GreatingDaysViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 28.02.2025.
//

import Foundation

class GreatingDaysViewModel: ObservableObject {
    
    let coordinator: MainCoordinatorPresenter
    
    init(coordinator: MainCoordinatorPresenter) {
        self.coordinator = coordinator
    }
    
}

extension GreatingDaysViewModel {
    
    func makeBackButton() {
        coordinator.navigate(to: .main)
    }
    
}
