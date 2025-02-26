//
//  OnboardingTempViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import Foundation
import SwiftUICore

struct OnboardingModel: Identifiable {
    var id: Int
    var title: LocalizedStringKey
    var description: LocalizedStringKey
    var button: LocalizedStringKey
    var image: ImageHelper.massive
    let action: () -> ()
}
