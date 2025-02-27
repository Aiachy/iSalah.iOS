//
//  MainHeaderView.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import SwiftUI

struct MainHeaderView: View {
    
    @EnvironmentObject var salah: iSalahState
    @Binding var version: Bool
    
    let navToCompass: () -> ()
    
    init(_ version: Binding<Bool>,
         navToCompass: @escaping () -> ()) {
        _version = version
        
        self.navToCompass = navToCompass
    }
    
    var body: some View {
        HStack(spacing: 20) {
            hicriCalenderAndLocationView
            Spacer()
            if version {
                PrayerCountdownView()
            }
            compassView
        }
        .frame(width: size9)
    }
}

#Preview {
    ZStack {
        BackgroundView()
        MainHeaderView(.constant(false)) { }
    }
        .environmentObject(mockSalah)
}

private extension MainHeaderView {
    
    var hicriCalenderAndLocationView: some View {
        VStack(alignment: .leading) {
            Text(Date().toFormattedHijri())
                .font(FontHandler.setDubaiFont(weight: .bold, size: .s))
            Text("\(salah.user.location?.district ?? ""), \(salah.user.location?.city ?? "")")
                .font(FontHandler.setDubaiFont(weight: .regular, size: .xs))
        }
        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
    }
    
    var compassView: some View {
        ImageHandler.getIcon(salah, image: .compass)
            .scaledToFit()
            .foregroundStyle(ColorHandler.getColor(salah, for: .light))
            .frame(width: dh(0.055))
            .onTapGesture(perform: navToCompass)
    }
    
}
