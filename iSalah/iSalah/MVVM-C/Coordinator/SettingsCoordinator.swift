//
//  SettingsCoordinator.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

//MARK: Protocol
private protocol SettingsProtocol {
    func navigate(to destination: SettingsCoordinators)
}
//MARK: Coordinators
enum SettingsCoordinators {
    case settings
    case profile
    case theme
    case accessibility
    case notifications
}
//MARK: Presenter
class SettingsCoordinatorPresenter: ObservableObject, SettingsProtocol {
    
    @Published var currentView: SettingsCoordinators
    let parent: GeneralCoordinatorPresenter
    
    init(parent: GeneralCoordinatorPresenter = .init()) {
        self.currentView = .settings
        self.parent = parent
    }
    
    func navigate(to destination: SettingsCoordinators) {
        withAnimation(.linear) {
            currentView = destination
        }
    }
    
    
    
}
//MARK: SettingsCoordinator
struct SettingsCoordinator: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var coordinator: SettingsCoordinatorPresenter
    let parentCoordinates: GeneralCoordinatorPresenter
    
    init(
        parent parentCoordinates: GeneralCoordinatorPresenter
    ) {
        _coordinator = StateObject(wrappedValue: SettingsCoordinatorPresenter(parent: parentCoordinates))
        self.parentCoordinates = parentCoordinates
    }
    
    var body: some View {
        ZStack {
            switch coordinator.currentView {
            case .settings:
                SettingsView(coordinator)
            case .profile:
                ProfileView(coordinator)
            case .theme:
                ThemeView(coordinator)
            case .accessibility:
                AccessibilityView(coordinator)
            case .notifications:
                NotificationView(coordinator)
            }
        }
        .onChange(of: coordinator.currentView, perform: { newValue in
            if newValue == .settings {
                parentCoordinates.isHidingNavbar = false
            } else {
                parentCoordinates.isHidingNavbar = true
            }
        })
        .environmentObject(salah)
    }
}

#Preview {
    SettingsCoordinator(parent: .init())
        .environmentObject(mockSalah)
}

