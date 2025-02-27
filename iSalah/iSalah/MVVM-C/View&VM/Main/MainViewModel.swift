//
//  MainViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import Foundation

class MainViewModel: ObservableObject {
    
    @Published var isHidingHeader: Bool
    let coordinator: GeneralCoordinatorPresenter
    
    init(isHidingHeader: Bool = false,
         coordinator: GeneralCoordinatorPresenter) {
        self.isHidingHeader = isHidingHeader
        self.coordinator = coordinator
    }
    
}

extension MainViewModel {
    
    func navigationToCompass() {
        coordinator.navigate(to: .compass)
    }
    
    
    
}
