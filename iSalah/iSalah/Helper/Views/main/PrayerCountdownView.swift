//
//  PrayerCountdownView_Pulse.swift
//  iSalah
//
//  Created on 27.02.2025.
//

import SwiftUI

struct PrayerCountdownView: View {
    @EnvironmentObject var salah: iSalahState

    @State private var timer: Timer?
    
    // Animation states
    @State private var secondsOpacity: Double
    @State private var minutesOpacity: Double
    @State private var hoursOpacity: Double
    
    @State private var hours: String
    @State private var minutes: String
    @State private var seconds: String
    init(
        timer: Timer? = nil,
        
        secondsOpacity: Double = 1.0,
        minutesOpacity: Double = 1.0,
        hoursOpacity: Double = 1.0,
        
        hours: String = "00",
        minutes: String = "00",
        seconds: String = "00"
    ) {
        self.timer = timer

        self.secondsOpacity = secondsOpacity
        self.minutesOpacity = minutesOpacity
        self.hoursOpacity = hoursOpacity
        
        
        self.hours = hours
        self.minutes = minutes
        self.seconds = seconds
      
    }
    
    var body: some View {
        HStack(alignment: .center,spacing: 8) {
            // Hours
            timeBlock(
                value: hours,
                label: "hours",
                opacity: hoursOpacity
            )
            
            twoPointView
            
            // Minutes
            timeBlock(
                value: minutes,
                label: "minutes",
                opacity: minutesOpacity
            )
            
            twoPointView
            
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
        .onChange(of: salah.user.location?.country, newCountryDetection)
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

private extension PrayerCountdownView {
    
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
    
    func newCountryDetection() {
        timer?.invalidate()
        timer = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            startTimer()
        }
    }
}
