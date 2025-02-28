//
//  PrayerCountdownView_Pulse.swift
//  iSalah
//
//  Created on 27.02.2025.
//

import SwiftUI

struct PrayerCountdownView: View {
    @EnvironmentObject var salah: iSalahState
    @State private var hours: String = "00"
    @State private var minutes: String = "00"
    @State private var seconds: String = "00"
    @State private var timer: Timer?
    
    // Animation states
    @State private var secondsOpacity: Double = 1.0
    @State private var minutesOpacity: Double = 1.0
    @State private var hoursOpacity: Double = 1.0
    
    var body: some View {
        HStack(spacing: 8) {
            // Hours
            timeBlock(
                value: hours,
                label: "hours",
                opacity: hoursOpacity
            )
            
            Text(":")
                .font(FontHandler.setNewYorkFont(weight: .bold, size: .xl))
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .offset(y: -4)
            
            // Minutes
            timeBlock(
                value: minutes,
                label: "minutes",
                opacity: minutesOpacity
            )
            
            Text(":")
                .font(FontHandler.setNewYorkFont(weight: .bold, size: .xl))
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .offset(y: -4)
            
            // Seconds
            timeBlock(
                value: seconds,
                label: "seconds",
                opacity: secondsOpacity
            )
        }
        .frame(width: dw(0.36))
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
            timer = nil
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        PrayerCountdownView()
    }
    .environmentObject(mockSalah)
}

private extension PrayerCountdownView {
    private func timeBlock(value: String, label: String, opacity: Double) -> some View {
        ZStack {
            VStack(spacing: 2) {
                CustomRectangleShape(radius: 8, corners: [.topLeft, .topRight])
                    .fill(ColorHandler.getColor(salah, for: .light))
                    .frame(width: dw(0.08), height: dh(0.025))
                CustomRectangleShape(radius: 8, corners: [.bottomLeft, .bottomRight])
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
    
    private func startTimer() {
        guard let location = salah.user.location else { return }
        
        var previousHours = "00"
        var previousMinutes = "00"
        var previousSeconds = "00"
        
        timer = PrayerTimeService.shared
            .startRemainingTimeTimer(
                for: location
            ) { prayerName, hrs, mins, secs in
                // Check if seconds changed
                if previousSeconds != secs {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        self.secondsOpacity = 0.5
                    }
                
                    // Reset opacity after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.secondsOpacity = 1.0
                        }
                    }
                    previousSeconds = secs
                }
            
                // Check if minutes changed
                if previousMinutes != mins {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.minutesOpacity = 0.5
                    }
                
                    // Reset opacity after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.minutesOpacity = 1.0
                        }
                    }
                    previousMinutes = mins
                }
            
                // Check if hours changed
                if previousHours != hrs {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        self.hoursOpacity = 0.5
                    }
                
                    // Reset opacity after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            self.hoursOpacity = 1.0
                        }
                    }
                    previousHours = hrs
                }
            
                // Update the values
                self.hours = hrs
                self.minutes = mins
                self.seconds = secs
            }
    }
}
