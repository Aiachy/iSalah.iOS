//
//  SplashView.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import SwiftUI

struct SplashView: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: SplashViewModel
    
    init() {
        _vm = StateObject(wrappedValue: SplashViewModel())
    }
    
    var body: some View {
        ZStack {
            if vm.isAppReady {
                GeneralCoordinator()
            } else {
                splashView
            }
        }
        .environmentObject(salah)
    }
}

#Preview {
    SplashView()
        .environmentObject(mockSalah)
}

private extension SplashView {
    
    var splashView: some View {
        ZStack {
            Group {
                BackgroundView()
                ImageHandler.getIcon(salah, image: .allah, render: .original)
                    .scaledToFit()
            }
            .ignoresSafeArea()
            VStack {
                Spacer()
                Text("App Beta\n\(salah.user.harvest.appVersion) (\(salah.user.harvest.buildNumber))")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(ColorHandler.getColor(salah, for: .light))
            }
        }
        .onAppear {
            vm.createUser(salah.user) { user in
                DispatchQueue.main.async {
                    salah.user = user
                }
            }
        }
        
    }
    
}
