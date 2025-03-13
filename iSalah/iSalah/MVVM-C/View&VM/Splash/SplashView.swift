//
//  SplashView.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import SwiftUI
//MARK: View
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
//MARK: Preview
#Preview {
    SplashView()
        .environmentObject(mockSalah)
}
//MARK: Views
private extension SplashView {
    
    var splashView: some View {
        ZStack {
            Group {
                BackgroundView()
                ImageHandler.getIcon(salah, image: .allah, render: .original)
                    .scaledToFit()
            }
            .ignoresSafeArea()
            
        }
        .fullScreenCover(isPresented: $vm.isAppUpdateRequired, content: {
            UpdateRequiredView()
        })
        
        .onAppear {
            vm.createUser(salah.user) { user in
                DispatchQueue.main.async {
                    salah.user = user
                }
            }
        }
        
    }
    
}
