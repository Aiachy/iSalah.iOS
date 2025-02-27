//
//  UserInfoModel.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import Foundation

struct UserInfoModel {
    
    var isPremium: Bool
    var gender: String?
    var premiumType: String?
    
    init(
        isPremium: Bool = false,
        gender: String? = nil,
        premiumType: String? = nil
    ) {
        self.isPremium = isPremium
        self.gender = gender
        self.premiumType = premiumType
    }
    
}
