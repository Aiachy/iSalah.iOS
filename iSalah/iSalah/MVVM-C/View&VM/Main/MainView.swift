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
        ZStack {
            BackgroundView()
            ScrollView(.vertical) {
                VStack {
                    headerView
                    TodayPrayView(IslamicPrayerData.prayers.randomElement()!)
                        .padding(.top)
                    Rectangle()
                        .frame(height: dh(0.08))
                        .opacity(0)
                }
            }
        }
        .environmentObject(salah)
    }
}

#Preview {
    MainView()
        .environmentObject(mockSalah)
}

//MARK: Header
private extension MainView {
    
    var headerView: some View {
        VStack(spacing: -5) {
            MainHeaderView($vm.isHidingHeader, navToCompass: vm.navigationToCompass)
            if !vm.isHidingHeader {
                EventAndTimeView()
                PrayerCountdownView()
                    .padding(.bottom)
                mosqueView
                MosqueCallTimerView()
            }
        }
    }
    
    var mosqueView: some View {
        ImageHandler.getMassive(salah, image: [.mosque1, .mosque2].randomElement() ?? .mosque1)
            .scaledToFit()
            .frame(width: size9)
    }
    
}
