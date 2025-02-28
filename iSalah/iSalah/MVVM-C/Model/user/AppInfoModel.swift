//
//  AppInfoModel.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import Foundation

struct AppInfoModel: Codable {
    var theme: String
    
    init(theme: String = "Medina Evening") {
        self.theme = theme
    }
}
