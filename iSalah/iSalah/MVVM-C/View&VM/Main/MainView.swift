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
            /// Background
            BackgroundView()
            VStack {
                /// Header
                MainHeaderView(
                    $vm.isHidingHeader,
                    navToCompass: vm.navigationToCompass
                )
                /// Custom Scroll
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
                        /// Scroll Info Header
                        headerView
                        /// Today pray
                        TodayHadisView(
                            IslamicPrayerData.getDailyPrayer()
                        )
                        .padding(.top)
                        /// Navs Button
                        HStack {
                            /// Tasbih
                            MainNavButtonView(
                                .init(
                                    .tesbih,
                                    version: 1,
                                    title: "Tasbih",
                                    action: { vm.navigationToTasbih() }
                                )
                            )
                            /// Quran
                            MainNavButtonView(
                                .init(
                                    .quran,
                                    version: 1,
                                    title: "Quran",
                                    action: { vm.navigationToQuran() }
                                )
                            )
                            .opacity(0)
                            .disabled(true)
                            
                        }
                        .padding(.horizontal)
                        .padding(.vertical,8)
                        /// Greating Days
                        CardGreatingDaysView(
                            GreatingDaysData.getDaysFor2025(),
                            action: vm.navigationToGreating
                        )
                    }
                    .padding(.top)
                }
                if !salah.user.checkIsPremium() {
                    BannerAdView()
                        .frame(height: dh(0.058))
                }
                /// TabBar spacer
                Rectangle()
                    .opacity(0.001)
                    .frame(height: dh(0.095))
            }
        }
        .interstitialAd(
            $vm.isShowingInterstitialAd,
            isP: salah.user.checkIsPremium()
        )
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
                ClockCountdownView()
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
