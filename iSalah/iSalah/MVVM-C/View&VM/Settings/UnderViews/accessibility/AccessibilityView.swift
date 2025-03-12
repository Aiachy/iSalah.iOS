//
//  AccessibilityView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI
//MARK: View
struct AccessibilityView: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: AccessibilityViewModel
    
    init(
        _ coordinator: SettingsCoordinatorPresenter
    ) {
        _vm = StateObject(wrappedValue: AccessibilityViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack {
                /// Header
                SettingsHeaderView("Accessibility", back: vm.makeBackButton)
                ScrollView(.vertical) {
                    /// Sub Title
                    SettingsSubTittleView("Used by Application")
                        .frame(width: dw(0.9))
                    locationRowView
                }
              
            }
        }
        /// Sheets
        .sheet(isPresented: $vm.isLocationSheetActive) {
            SearchLocationView { location in
                salah.user.location = location
            }
            .modifier(SheetModifier(0.9))
        }
    }
}
//MARK: Preview
#Preview {
    AccessibilityView(.init())
        .environmentObject(mockSalah)
}
//MARK: Views
private extension AccessibilityView {
    var locationRowView: some View {
        HStack {
            Text("Location")
            Spacer()
            Text(salah.user.getLocationString())
        }
        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
        .frame(width: size9)
        .onTapGesture {
            vm.isLocationSheetActive.toggle()
        }
    }
}
