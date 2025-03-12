//
//  ClockCountdownView.swift
//  iSalah
//
//  Created on 27.02.2025.
//  Updated on 13.03.2025.
//

import SwiftUI

struct ClockCountdownView: View {
    @EnvironmentObject var salah: iSalahState
    
    // Animation states
    @State private var secondsOpacity: Double = 1.0
    @State private var minutesOpacity: Double = 1.0
    @State private var hoursOpacity: Double = 1.0
    
    // Previous values to track changes
    @State private var previousSeconds: String = "00"
    @State private var previousMinutes: String = "00"
    @State private var previousHours: String = "00"
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Hours
            timeBlock(
                value: salah.clockService.hours,
                label: "hours",
                opacity: hoursOpacity
            )
            
            twoPointView
            
            // Minutes
            timeBlock(
                value: salah.clockService.minutes,
                label: "minutes",
                opacity: minutesOpacity
            )
            
            twoPointView
            
            // Seconds
            timeBlock(
                value: salah.clockService.seconds,
                label: "seconds",
                opacity: secondsOpacity
            )
        }
        .frame(width: dw(0.36))
        .onAppear {
            // Make sure timer starts if not already running
            if let location = salah.user.location {
                salah.clockService.startTimer(for: location)
            }
        }
        .onChange(of: salah.user.location?.country) { _ in
            // Restart timer when country changes
            if let location = salah.user.location {
                salah.clockService.stopTimer()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    salah.clockService.startTimer(for: location)
                }
            }
        }
        // Monitor for changes to animate
        .onReceive(salah.clockService.$seconds) { newSeconds in
            if previousSeconds != newSeconds {
                animateOpacity(for: $secondsOpacity, duration: 0.2)
                previousSeconds = newSeconds
            }
        }
        .onReceive(salah.clockService.$minutes) { newMinutes in
            if previousMinutes != newMinutes {
                animateOpacity(for: $minutesOpacity, duration: 0.3)
                previousMinutes = newMinutes
            }
        }
        .onReceive(salah.clockService.$hours) { newHours in
            if previousHours != newHours {
                animateOpacity(for: $hoursOpacity, duration: 0.4)
                previousHours = newHours
            }
        }
    }
    
    private func animateOpacity(for opacityState: Binding<Double>, duration: Double) {
        withAnimation(.easeInOut(duration: duration)) {
            opacityState.wrappedValue = 0.5
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.easeInOut(duration: duration)) {
                opacityState.wrappedValue = 1.0
            }
        }
    }
}

private extension ClockCountdownView {
    private func timeBlock(value: String, label: String, opacity: Double) -> some View {
        ZStack {
            VStack(spacing: 2) {
                CustomRectangleShape(radius: 8, corners: [.topLeft, .topRight])
                    .fill(ColorHandler.getColor(salah, for: .light))
                    .frame(width: dw(0.08), height: dh(0.025))
                CustomRectangleShape(
                    radius: 8,
                    corners: [.bottomLeft, .bottomRight]
                )
                .fill(ColorHandler.getColor(salah, for: .light))
                .frame(width: dw(0.08), height: dh(0.025))
            }
            .shadow(radius: 10)
            VStack(spacing: 2) {
                   
                Text(value)
                    .font(FontHandler.setNewYorkFont(weight: .black, size: .xl))
                    .foregroundStyle(
                        ColorHandler.getColor(salah, for: .shadow)
                    )
                    .monospacedDigit()
                    .opacity(opacity)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 2)
    }
    
    var twoPointView: some View {
        VStack(alignment: .center) {
            ForEach(0..<2) { _ in
                Circle()
                    .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                    .frame(width: 4, height: 4)
            }
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        ClockCountdownView()
    }
    .environmentObject(mockSalah)
}
