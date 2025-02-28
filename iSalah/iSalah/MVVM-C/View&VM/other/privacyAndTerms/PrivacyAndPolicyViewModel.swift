//
//  PrivacyAndPolicyViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import Foundation

class PrivacyAndPolicyViewModel: ObservableObject {
    
    @Published var section: Int
    
    init(section: Int = 0) {
        self.section = section
    }
    
}
