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
    
    init(_ coordinator: MainCoordinatorPresenter) {
        _vm = StateObject(wrappedValue: MainViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                MainHeaderView(
                    $vm.isHidingHeader,
                    navToCompass: vm.navigationToCompass
                )
                
                ScrollViewWithOffset { offset in
                    let threshold: CGFloat = 100
                    
                    withAnimation(.easeInOut(duration: 0.2)) {
                        if offset > threshold && !vm.isHidingHeader {
                            HapticManager.shared.trigger(.light)
                            vm.isHidingHeader = true
                        }
                        else if offset < 20 && vm.isHidingHeader {
                            HapticManager.shared.trigger(.light)
                            vm.isHidingHeader = false
                        }
                    }
                } content: {
                    VStack {
                        headerView
                        TodayPrayView(
                            IslamicPrayerData.getDailyPrayer()
                        )
                        .padding(.top)
                        Rectangle()
                            .opacity(0.001)
                            .frame(height: dh(0.095))
                    }
                }
            }
        }
        .environmentObject(salah)
    }
}

#Preview {
    MainView(.init())
        .environmentObject(mockSalah)
}

//MARK: Header
private extension MainView {
    
    var headerView: some View {
        VStack(spacing: -5) {
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
        ImageHandler
            .getMassive(
                salah,
                image: [.mosque1, .mosque2].randomElement() ?? .mosque1,
                render: .template
            )
            .scaledToFit()
            .foregroundStyle(ColorHandler.getColor(salah, for: .islamicAlt))
            .frame(width: size9)
    }
}
