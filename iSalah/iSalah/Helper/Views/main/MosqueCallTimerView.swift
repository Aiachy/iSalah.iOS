//
//  MosqueCallTimerView.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import SwiftUI
//MARK: View
struct MosqueCallTimerView: View {
    
    @EnvironmentObject var salah: iSalahState
    @State private var prayerTimes: [PrayerTime] = []
    @State private var isLoading = true
    
    // Reference to notification manager
    
    var body: some View {
        ZStack {
            ColorHandler.getColor(salah, for: .islamicAlt)
            if salah.user.location == nil {
               Text("You need to enable location services to use this feature.")
                    .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                    .font(FontHandler.setNewYorkFont(weight: .semibold, size: .xs))
            } else if isLoading {
                ProgressView()
                    .tint(ColorHandler.getColor(salah, for: .light))
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
            // Check notification authorization when view appears
            loadPrayerTimes()
        }
        .onChange(of: salah.user.location?.country) {
            loadPrayerTimes()
        }
    }
    
}
//MARK: Preview
#Preview {
    ZStack {
        BackgroundView()
        MosqueCallTimerView()
    }
    .environmentObject(mockSalah)
}
//MARK: Views
private extension MosqueCallTimerView {
    
    func makeCallTimer(_ title: LocalizedStringKey, time: String, isPassed: Bool) -> some View {
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
//MARK: Func
private extension MosqueCallTimerView {
    func loadPrayerTimes() {
        guard let location = salah.user.location else {
            prayerTimes = []
            isLoading = false
            return
        }
        print("iSalah: MosqueCallTimerView - loadPrayerTimes - \(location)")
        isLoading = true
        Task {
            let times = await PrayerTimeService.shared.getPrayerTimes(
                for: location
            )
            
            DispatchQueue.main.async {
                self.prayerTimes = times
                self.isLoading = false
                
                // Schedule notifications based on the newly loaded prayer times
                if !times.isEmpty {
                    self.schedulePrayerNotifications(for: times)
                }
            }
        }
    }
    
    func schedulePrayerNotifications(for prayerTimes: [PrayerTime]) {
        print("iSalah: MosqueCallTimerView - schedulePrayerNotifications")
        
        // Use the NotificationManager to schedule notifications for prayer times
        NotificationManager.shared.schedulePrayerNotifications(for: prayerTimes)
    }
}
