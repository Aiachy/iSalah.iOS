//
//  TodayPrayView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct TodayPrayView: View {
    
    @EnvironmentObject var salah: iSalahState
    @State private var isLikedPray: Bool = false
    @State private var index: Int

    let model: TodayPrayerModel
    
    init(index: Int = 0,
         _ model: TodayPrayerModel ) {
        self.index = index
        self.model = model
    }
    
    var body: some View {
            
        VStack(spacing: 18) {
            makeHeaderView(model.title, sub: model.subTitle)
            makeContentView(model.arabic, reading: model.reading, meal: model.meal.translated)
            makeBottomView(model)
                
        }
        .padding(10)
        .frame(width: size9)
        .background(backgroundView)
    }
}
//MARK: Preview
#Preview {
    ZStack {
        BackgroundView()
        TodayPrayView(
            .init(id: "0",
                  title: "Sahih Bukhari",
                  subTitle: "Hadees 1",
                  arabic: "رَبَّنَا وَاجْعَلْنَا مُسْلِمَيْنِ لَكَ وَمِن ذُرِّيَّتِنَا أُمَّةً مُّسْلِمَةً لَّكَ وَأَرِنَا مَنَاسِكَنَا وَتُبْ عَلَيْنَآ إِنَّكَ أَنتَ التَّوَّابُ الرَّحِيمُ",
                  reading: "Rabbana wa-j'alna Muslimayni laka wa min Dhurriyatina 'Ummatan Muslimatan laka wa 'Arina Manasikana wa tub 'alayna 'innaka 'antat-Tawwabu-Raheem",
                  meal: "Oh our Lord! Make us Muslims, a people who submit to Your will; and from our descendants, an illiterate Muslim who prostrates himself to Your will; show us our places of worship; and accept our repentance; for You are the Most Repentant, the Most Merciful.")
            
        )
    }
    .environmentObject(mockSalah)
}
//MARK: Views
private extension TodayPrayView {
    
    private var backgroundView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(ColorHandler.getColor(salah, for: .islamicAlt))
            RoundedRectangle(cornerRadius: 16)
                .stroke(ColorHandler.getColor(salah, for: .gold))
        }
      
    }
    /// Header View
    private func makeHeaderView(_ title: String, sub: String) -> some View {
        HStack(spacing: 6) {
            Text("Today Pray")
                .font(FontHandler.setDubaiFont(weight: .bold, size: .m))
            Spacer()
            VStack(alignment: .trailing) {
                Text(title)
                    .font(
                        FontHandler.setDubaiFont(weight: .regular, size: .xxs)
                    )
                Text(sub)
                    .font(FontHandler.setDubaiFont(weight: .light, size: .xxs))
            }
        }
        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
    }
    /// Content View
    private func makeContentView(_ arabic: String, reading: String, meal: String) -> some View {
        VStack(spacing: 12) {
            Text(arabic)
            .foregroundStyle(ColorHandler.getColor(salah, for: .gold))
            
            Text(reading)
            .font(FontHandler.setDubaiFont(weight: .regular, size:.xxs))
            .foregroundStyle(ColorHandler.getColor(salah, for: .light))
            .padding(.bottom)
            
            Text(meal)
            .font(FontHandler.setDubaiFont(weight: .medium, size: .xs))
            .foregroundStyle(ColorHandler.getColor(salah, for: .light))
        }
        .multilineTextAlignment(.center)
    }
    
    
    
    private func makeBottomView(_ model: TodayPrayerModel) -> some View {
        let isContain: Bool = isLikedPray
        
        return HStack {
            makeButtonView {
                ImageHandler.getIcon(salah, image: isContain ? .heartFill : .heart)
                    .scaledToFit()
                    .foregroundStyle(
                        ColorHandler.getColor(salah, for: .light)
                    )
                    .padding(10)
            } action: {
                if isContain {
                    isLikedPray = false
                } else {
                    isLikedPray = true
                }
            }

            Spacer()
            makeButtonView({
                ImageHandler.getIcon(salah, image: .share)
                    .scaledToFit()
                    .foregroundStyle(
                        ColorHandler.getColor(salah, for: .light)
                    )
                    .padding(10)
            }, action: {
                PrayShareManager.shared.sharePrayer(model)
                            
            })
                
        }
    }
    
    
    
}
//MARK: Helper Views
private extension TodayPrayView {
    private func makeButtonView(_ view: () -> some View, action: @escaping () -> ()) -> some View {
        ZStack {
            Circle()
                .stroke(ColorHandler.getColor(salah, for: .gold))
            Circle()
                .fill(ColorHandler.getColor(salah, for: .islamicAlt))
            view()
        }
        .frame(width: dw(0.1))
        .onTapGesture {
            HapticManager.shared.tabSelection()
            withAnimation {
                action()
            }
        }
            
    }
}
