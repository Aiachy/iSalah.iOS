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
    
    case compass
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
            case .settings:
                EmptyView()
                
            case .compass:
                EmptyView()
            }
        }
        .overlay(alignment: .bottom, content: {
//            if coordinator.currentView == .main || coordinator.currentView == .settings {
                tabBarView
//            }
        })
        .ignoresSafeArea()
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
                Button {
                    coordinator.navigate(to: .main)
                } label: {
                    ZStack {
                        tabBarButtonView
                        ImageHandler.getIcon(salah, image: .main)
                            .scaledToFit()
                            .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                            .frame(width: dw(0.1))
                    }
                        
                }
                
                Button {
                    coordinator.navigate(to: .settings)
                } label: {
                    ZStack {
                        tabBarButtonView
                        ImageHandler.getIcon(salah, image: .settings)
                            .scaledToFit()
                            .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                            .frame(width: dw(0.1))
                    }
                }

                
            }
        }
        .frame(height: dh(0.08))
    }
    
    var tabBarButtonView: some View {
      
        ZStack {
            Circle()
                .fill(ColorHandler.getColor(salah, for: .islamicAlt))
            Circle()
                .stroke(ColorHandler.getColor(salah, for: .gold))
        }
        .frame(width: dw(0.1))

    }
    
}
