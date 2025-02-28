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
    case settings
    
}
//MARK: Presenter
class GeneralCoordinatorPresenter: ObservableObject, GeneralProtocol {
    
    @Published var currentView: GeneralCoordinators
    @Published var isHidingNavbar: Bool
    
    init(isHidingNavbar: Bool = false) {
        let checkOnbHaveBeenShown = UserDefaults.standard.bool(forKey: onboardingFinishedKey)
        
        self.currentView = checkOnbHaveBeenShown ? .main : .onboarding
        self.isHidingNavbar = isHidingNavbar

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
                MainCoordinator(parent: coordinator)
            case .settings:
                SettingsCoordinator(parent: coordinator)
            }
        }
        .overlay(alignment: .bottom, content: {
            if !coordinator.isHidingNavbar && (coordinator.currentView == .main || coordinator.currentView == .settings ) {
                tabBarView
            }
        })
        .edgesIgnoringSafeArea(.bottom)
        .environmentObject(salah)
    }
}

#Preview {
    GeneralCoordinator()
        .environmentObject(mockSalah)
}

private extension GeneralCoordinator {
    
    var tabBarView: some View {
        ZStack {
            ColorHandler.getColor(salah, for: .islamicAlt)
            HStack {
                Spacer()
                Button {
                    coordinator.navigate(to: .main)
                } label: {
                    ZStack {
                        tabBarButtonView(coordinator.currentView == .main)
                        ImageHandler.getIcon(salah, image: .main)
                            .scaledToFit()
                            .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                            .frame(width: dw(0.05))
                    }
                        
                }
                Spacer()
                Button {
                    coordinator.navigate(to: .settings)
                } label: {
                    ZStack {
                        tabBarButtonView(coordinator.currentView == .settings)
                        ImageHandler.getIcon(salah, image: .settings)
                            .scaledToFit()
                            .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                            .frame(width: dw(0.05))
                            
                    }
                }
                Spacer()
            }
            .offset(y: dh(-0.01))
        }
        .frame(height: dh(0.095))
    }
    
    func tabBarButtonView(_ isSelected: Bool) -> some View {
      
        ZStack {
            Circle()
                .fill(ColorHandler.getColor(salah, for: .islamicAlt))
            Circle()
                .stroke(ColorHandler.getColor(salah, for: isSelected ? .gold : .light))
        }
        .frame(width: dw(0.13))

    }
    
}
