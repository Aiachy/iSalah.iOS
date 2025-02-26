//
//  iSalahState.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import Foundation

class iSalahState: ObservableObject {
    
    @Published var user: UserModel
    
    init(user: UserModel = .init()) {
        self.user = user
    }
    
}
