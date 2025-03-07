//
//  CompassView.swift
//  iSalah
//
//  Created by Mert Türedü on 28.02.2025.
//

import SwiftUI
import CoreLocation
//MARK: View
struct CompassView: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: CompassViewModel
    
    init(
        _ coordinator: MainCoordinatorPresenter
    ) {
        _vm = StateObject(wrappedValue: CompassViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack(spacing: 20) {
                SettingsHeaderView("Qibla Compass", back: vm.makeBackButton)
                Spacer()
                if salah.user.location != nil {
                    compassView
                } else {
                    locationNotAvailable
                }
                Spacer()
                locationTextView
            }
            .padding(.bottom, 20)
            .onAppear {
                vm.startCompassUpdates()
                vm.calculateQiblaDirection(for: salah.user.location?.coordinate)
            }
            .onDisappear {
                vm.stopCompassUpdates()
            }
        }
    }
}
//MARK: Preview
#Preview {
    CompassView(.init())
        .environmentObject(mockSalah)
}

private extension CompassView {

    var compassView: some View {
        ZStack {
            Circle()
                .stroke(
                    ColorHandler.getColor(salah, for: .light),
                    lineWidth: 5
                )
                .frame(width: size9, height: size9)
            
            Circle()
                .fill(
                    ColorHandler.getColor(salah, for: .islamic)
                )
                .frame(width: size9, height: size9)
            
            ZStack {
                if let qiblaDirection = vm.qiblaDirection {
                    /// Qibla
                    ImageHandler.getIcon(salah, image: .qible)
                        .scaledToFit()
                        .frame(width: dw(0.1))
                        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                        .position(x: calculateX(angle: qiblaDirection),
                                  y: calculateY(angle: qiblaDirection))
                    /// Line
                    ImageHandler.getIcon(salah, image: .compassLine)
                        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                        .scaledToFit()
                        .frame(width: dw(0.12))
                        .offset(y: dh(-0.05))
                        .rotate(-30)
                    }
            }
            .frame(width: size9, height: size9)
            .rotationEffect(Angle(degrees: -Double(vm.compassHeading)))

        }
        .rotationEffect(.degrees(180))
        .frame(width: size9, height: size9)
    }
    
    @ViewBuilder
    var locationTextView: some View {
        if let location = salah.user.location {
            VStack(spacing: 0) {
                Text("Your Location")
                    .foregroundStyle(ColorHandler.getColor(salah, for: .horizon))
                Text("\(location.district), \(location.city), \(location.country)")
                    .foregroundStyle(ColorHandler.getColor(salah, for: .light))
            }
            .font(FontHandler.setDubaiFont(weight: .bold, size: .l))
        }
    }
    
    var locationNotAvailable: some View {
        VStack {
            Text("Location not available")
                .font(FontHandler.setDubaiFont(weight: .medium, size: .l))
                .foregroundStyle(ColorHandler.getColor(salah, for: .horizon))
            Text("Please set your location to use the Qibla compass")
                .font(FontHandler.setDubaiFont(weight: .regular, size: .m))
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}

private extension CompassView {
    func calculateX(angle: Double) -> CGFloat {
        let radius = size9/2 - 30
        let centerX = size9/2
        let angleInRadians = angle * .pi / 180
        return centerX + radius * cos(angleInRadians)
    }
    
    func calculateY(angle: Double) -> CGFloat {
        let radius = size9/2 - 30
        let centerY = size9/2
        let angleInRadians = angle * .pi / 180
        return centerY + radius * sin(angleInRadians)
    }
}
