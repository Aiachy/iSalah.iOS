//
//  MainHeaderView.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//

import SwiftUI
//MARK: View
struct MainHeaderView: View {
    
    @EnvironmentObject var salah: iSalahState
    @Binding var version: Bool
    @State private var isSheetPresented: Bool
    
    let navToCompass: () -> ()
    
    init(_ version: Binding<Bool>,
         isSheetPresented: Bool = false,
         navToCompass: @escaping () -> ()) {
        _version = version
        self.isSheetPresented = isSheetPresented
        self.navToCompass = navToCompass
    }
    
    var body: some View {
        HStack(spacing: 10) {
            hicriCalenderAndLocationView
            Spacer()
            PrayerCountdownView()
                .opacity(version ? 1 : 0)
            compassView
        }
        .sheet(isPresented: $isSheetPresented, content: {
            SearchLocationView { location in
                salah.user.location = location
                isSheetPresented = false
            }
            .modifier(SheetModifier(0.99))
        })
        .frame(width: size9, height: dh(0.06))
    }
}
//MARK: Preview
#Preview {
    ZStack {
        BackgroundView()
        MainHeaderView(.constant(false)) { }
    }
    .environmentObject(mockSalah)
}
//MARK: Views
private extension MainHeaderView {
    
    var hicriCalenderAndLocationView: some View {
        VStack(alignment: .leading) {
            Text(Date().toFormattedHijri())
                .font(FontHandler.setDubaiFont(weight: .bold, size: .s))
            Text(salah.user.getLocationString())
                .font(FontHandler.setDubaiFont(weight: .regular, size: .xs))
        }
        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
        .onTapGesture {
            isSheetPresented.toggle()
        }
    }
    
    var compassView: some View {
        ImageHandler.getIcon(salah, image: .compass)
            .scaledToFit()
            .foregroundStyle(ColorHandler.getColor(salah, for: .light))
            .frame(width: dw(0.1))
            .onTapGesture(perform: navToCompass)
    }
    
}
