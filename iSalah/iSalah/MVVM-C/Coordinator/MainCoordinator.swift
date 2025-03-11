//
//  MainCoordinator.swift
//  iSalah
//
//  Created by Mert Türedü on 28.02.2025.
//

import SwiftUI

//MARK: Protocol
private protocol MainProtocol {
    func navigate(to destination: MainCoordinators)
}
//MARK: Coordinators
enum MainCoordinators {
    case main
    case compass
    case greatingDays
    case tasbeeh
    case map
    case quran
    
}
//MARK: Presenter
class MainCoordinatorPresenter: ObservableObject, MainProtocol {
    
    @Published var currentView: MainCoordinators
    
    init() {
        self.currentView = .main
    }
    
    func navigate(to destination: MainCoordinators) {
        withAnimation(.linear) {
            currentView = destination
        }
    }
    
}
//MARK: MainCoordinator
struct MainCoordinator: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var coordinator = MainCoordinatorPresenter()
    let parentCoordinates: GeneralCoordinatorPresenter
    
    init(
        parent parentCoordinates: GeneralCoordinatorPresenter
    ) {
        self.parentCoordinates = parentCoordinates
    }
    
    var body: some View {
        ZStack {
            switch coordinator.currentView {
            
            case .main:
                MainView(coordinator)
            case .compass:
                CompassView(coordinator)
            case .greatingDays:
                GreatingDaysView(coordinator)
            case .tasbeeh:
                TasbeehView(coordinator)
            case .map:
                EmptyView()
            case .quran:
                QuranView(coordinator)
            }
        }
        .onChange(of: coordinator.currentView, perform: { newValue in
            if newValue == .main {
                parentCoordinates.isHidingNavbar = false
            } else {
                parentCoordinates.isHidingNavbar = true
            }
        })
        .environmentObject(salah)
    }
}

#Preview {
    MainCoordinator(parent: .init())
        .environmentObject(mockSalah)
}

