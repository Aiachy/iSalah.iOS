//
//  QuranViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 10.03.2025.
//

import Foundation

class QuranViewModel: ObservableObject {

    let coordinator: MainCoordinatorPresenter
    
    init(coordinator: MainCoordinatorPresenter) {
        self.coordinator = coordinator
    }
    
}

extension QuranViewModel {
    
    func makeBackButton() {
        coordinator.navigate(to: .main)
    }
    
}
