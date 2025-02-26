//
//  GeneralCoordinator.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import SwiftUI
//MARK: Protocol
private protocol GeneralProtocol {
    func navigate(to destination: GeneralCoordinators)
}
//MARK: Coordinators
enum GeneralCoordinators {
    case onboarding
    case main
}
//MARK: Presenter
class GeneralCoordinatorPresenter: ObservableObject, GeneralProtocol {
    
    @Published var currentView: GeneralCoordinators
    
    init() {
        let checkOnbHaveBeenShown = UserDefaults.standard.bool(forKey: onboardingFinishedKey)
        
        self.currentView = checkOnbHaveBeenShown ? .main : .onboarding
    }
    
    func navigate(to destination: GeneralCoordinators) {
        withAnimation(.linear) {
            currentView = destination
        }
    }
    
}
//MARK: GeneralCoordinator
struct GeneralCoordinator: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var coordinator = GeneralCoordinatorPresenter()
    
    var body: some View {
        ZStack {
            switch coordinator.currentView {
            case .onboarding:
                OnboardingView(coordinator)
            case .main:
                MainView(coordinator)
            }
        }
        .ignoresSafeArea(.keyboard)
        .environmentObject(salah)
    }
}

#Preview {
    GeneralCoordinator()
        .environmentObject(mockSalah)
}
