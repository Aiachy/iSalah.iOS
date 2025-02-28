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
    var harvest: HarvestModel
    var location: LocationSuggestion?
    
    init(
         info: UserInfoModel = .init(),
         appInfo: AppInfoModel = .init(),
         harvest: HarvestModel = .init(),
         location: LocationSuggestion? = nil
    ) {
        self.id = UserDefaults.standard.string(forKey: userIDKey)
        self.info = info
        self.appInfo = appInfo
        self.harvest = harvest
        self.location = location
    }
}

extension UserModel {
    
    var wrappedId: String {
        id ?? ""
    }
    
}

extension UserModel {
    func getLocationString() -> String {
        
        guard let location = location else {
            return ""
        }
        
        return "\(location.district), \(location.city)"
        
    }
}
