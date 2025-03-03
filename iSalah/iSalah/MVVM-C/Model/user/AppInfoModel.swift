//
//  AppInfoModel.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import Foundation

struct AppInfoModel: Codable {
    var theme: String
    var language: String
    
    init(theme: String = "Medina Evening",
         language: String = "en" ) {
        self.theme = theme
        self.language = Locale.current.language.languageCode?.identifier ?? language
    }
}
