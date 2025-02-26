//
//  MainView.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: MainViewModel
    
    init(_ coordinator: GeneralCoordinatorPresenter = .init()) {
        _vm = StateObject(wrappedValue: MainViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    MainView()
        .environmentObject(mockSalah)
}
