//
//  EventAndTimeView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct EventAndTimeView: View {
    
    @EnvironmentObject var salah: iSalahState
    @State private var eventAndTime: (name: LocalizedStringKey, time: String)?
    
    init(_ eventAndTime: (name: LocalizedStringKey, time: String)? = nil) {
        self.eventAndTime = eventAndTime
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Text(eventAndTime?.name ?? "")
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .font(FontHandler.setDubaiFont(weight: .medium, size: .xxl))
                .padding(.bottom, -10)
            Text(eventAndTime?.time ?? "")
                .foregroundStyle(ColorHandler.getColor(salah, for: .horizon))
                .font(FontHandler.setDubaiFont(weight: .medium, size: .h2_5))
        }
        .frame(height: dh(0.082))
        .onAppear(perform: makeEventAndTimeText)
        .onChange(of: salah.user.location?.country, makeEventAndTimeText)
    }
}

#Preview {
    ZStack {
        BackgroundView()
        EventAndTimeView()
    }
    .environmentObject(mockSalah)
}

private extension EventAndTimeView {
    
    func makeEventAndTimeText() {
        Task {
            let location: LocationSuggestion? = salah.user.location
            eventAndTime = await PrayerTimeService.shared.getNextPrayerTimeInfo(for: location)
        }
        
    }
    
}
