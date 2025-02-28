//
//  GreatingDaysView.swift
//  iSalah
//
//  Created by Mert Türedü on 28.02.2025.
//

import SwiftUI

struct GreatingDaysView: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: GreatingDaysViewModel
    
    init (
        _ coordinator: MainCoordinatorPresenter
    ) {
        _vm = StateObject(wrappedValue: GreatingDaysViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                SettingsHeaderView("Blessed Days", back: vm.makeBackButton)
                ScrollView(.vertical) {
                    
                }
            }
        }
    }
}

#Preview {
    GreatingDaysView(.init())
        .environmentObject(mockSalah)
}
