//
//  MainViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import Foundation

class MainViewModel: ObservableObject {
    
    @Published var isHidingHeader: Bool
    let coordinator: MainCoordinatorPresenter
    
    init(isHidingHeader: Bool = false,
         coordinator: MainCoordinatorPresenter) {
        self.isHidingHeader = isHidingHeader
        self.coordinator = coordinator
    }
    
}

extension MainViewModel {
    
    func navigationToCompass() {
        coordinator.navigate(to: .compass)
    }
    
    
    
}
