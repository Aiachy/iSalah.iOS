//
//  MosqueCallTimerView.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import SwiftUI

struct MosqueCallTimerView: View {
    
    @EnvironmentObject var salah: iSalahState
    @State private var prayerTimes: [PrayerTime] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            ColorHandler.getColor(salah, for: .islamicAlt)
            if isLoading {
                ProgressView()
            } else {
                HStack(spacing: 5) {
                    ForEach(prayerTimes) { prayerTime in
                        makeCallTimer(
                            prayerTime.name,
                            time: prayerTime.timeString,
                            isPassed: prayerTime.isPassed
                        )
                    }
                }
            }
        }
        .frame(height: dh(0.06))

        .onAppear {
            print(Date())
            loadPrayerTimes()
        }
    }
    
}

#Preview {
    ZStack {
        BackgroundView()
        MosqueCallTimerView()
    }
    .environmentObject(mockSalah)
}

private extension MosqueCallTimerView {
    
    func makeCallTimer(_ title: String, time: String, isPassed: Bool) -> some View {
        VStack {
            Text(title)
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .font(FontHandler.setDubaiFont(weight: .medium, size: .m))
            Text(time)
                .foregroundStyle(ColorHandler.getColor(salah, for: .horizon))
                .font(FontHandler.setDubaiFont(weight: .medium, size: .xs))
                .opacity(isPassed ? 0.5 : 1.0)
        }
        .opacity(isPassed ? 0.7 : 1.0)
        .padding(.horizontal, 12)
    }
}

private extension MosqueCallTimerView {
    private func loadPrayerTimes() {
        guard let location = salah.user.location else {
            prayerTimes = []
            isLoading = false
            return
        }
        
        isLoading = true
        
        Task {
            let times = await PrayerTimeService.shared.getPrayerTimes(
                for: location
            )
            
            DispatchQueue.main.async {
                self.prayerTimes = times
                self.isLoading = false
            }
        }
    }
}
