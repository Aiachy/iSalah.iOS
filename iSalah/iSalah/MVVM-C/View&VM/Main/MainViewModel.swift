//
//  MainViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import Foundation

class MainViewModel: ObservableObject {
    
    @Published var isHidingHeader: Bool
    @Published var isShowingInterstitialAd: Bool
    let coordinator: MainCoordinatorPresenter
    
    init(isHidingHeader: Bool = false,
         isShowingInterstitialAd: Bool = false,
         coordinator: MainCoordinatorPresenter) {
        self.isHidingHeader = isHidingHeader
        self.isShowingInterstitialAd = isShowingInterstitialAd
        self.coordinator = coordinator
        
        makeMainView()
    }
    
}

extension MainViewModel {

    func makeMainView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isShowingInterstitialAd = true
        }
    }
    
    func navigationToCompass() {
        coordinator.navigate(to: .compass)
    }
    
    func navigationToGreating() {
        coordinator.navigate(to: .greatingDays)
    }
    
    func navigationToTasbih() {
        coordinator.navigate(to: .tasbeeh)
    }
    
}
