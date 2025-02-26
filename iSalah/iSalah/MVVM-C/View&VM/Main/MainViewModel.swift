//
//  MainViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import Foundation

class MainViewModel: ObservableObject {
    
    let coordinator: GeneralCoordinatorPresenter
    
    init(coordinator: GeneralCoordinatorPresenter) {
        self.coordinator = coordinator
    }
    
}
