//
//  UserModel.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import Foundation

struct UserModel {
    var id: String?
    var info: UserInfoModel
    var appInfo: AppInfoModel
    var location: LocationSuggestion?
    
    init(id: String? = nil,
         info: UserInfoModel = .init(),
         appInfo: AppInfoModel = .init(),
         location: LocationSuggestion? = nil) {
        self.id = id
        self.info = info
        self.appInfo = appInfo
        self.location = location
    }
}
