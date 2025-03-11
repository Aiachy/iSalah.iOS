//
//  MainNavButtonModel.swift
//  iSalah
//
//  Created by Mert Türedü on 10.03.2025.
//

import SwiftUI

struct MainNavButtonModel {
    let icon: ImageHelper.icon
    let version: Int
    let title: LocalizedStringKey
    let action: () -> ()
    
    init(_ icon: ImageHelper.icon,
         version: Int = 0,
         title: LocalizedStringKey,
         action: @escaping () -> Void) {
        self.icon = icon
        self.version = version
        self.title = title
        self.action = action
    }
}
