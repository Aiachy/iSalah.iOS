//
//  TodayHadisView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct TodayHadisView: View {
    
    @EnvironmentObject var salah: iSalahState
    @State private var isBackgroundAnimationActive: Bool = false
    @State private var isLikedPray: Bool = false
    @State private var index: Int
    @State private var translatedMeal: String
    
    let model: TodayHadisModel
    
    init(index: Int = 0,
         _ model: TodayHadisModel ) {
        self.index = index
        self.model = model
        self.translatedMeal = model.meal
    }
    
    var body: some View {
            
        VStack(spacing: 18) {
            makeHeaderView(model.title, sub: model.subTitle)
            makeContentView(model.arabic, reading: model.reading, meal: translatedMeal)
            makeBottomView(model)
        }
        .padding(10)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                isBackgroundAnimationActive = true
            }
        }
        .frame(width: size9)
        .background(backgroundView)
        .task {
            self.translatedMeal = await PrayerTranslationManager.shared.translate(text: model.meal)
        }
    }
}
//MARK: Preview
#Preview {
    ZStack {
        BackgroundView()
        TodayHadisView(
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
private extension TodayHadisView {
    
    private var backgroundView: some View {
        let isActive = isBackgroundAnimationActive
        let linear = LinearGradient(stops: [.init(color: ColorHandler.getColor(salah, for: isActive ? .islamicAlt : .horizon), location: 0),
                                            .init(color: ColorHandler.getColor(salah, for: isActive ? .horizon : .islamicAlt), location: 1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing)
        
        return ZStack {
            /// background
            RoundedRectangle(cornerRadius: 16)
                .fill(ColorHandler.getColor(salah, for: .islamicAlt))
            /// Strokes
            RoundedRectangle(cornerRadius: 16)
                .stroke(linear)
                .animation(.linear(duration: 5).repeatForever(), value: isBackgroundAnimationActive)
        }
      
    }
    /// Header View
    private func makeHeaderView(_ title: String, sub: String) -> some View {
        HStack(spacing: 6) {
            Text("Today Hadis")
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
    
    
    
    private func makeBottomView(_ model: TodayHadisModel) -> some View {
        let isContain: Bool = isLikedPray
        
        return HStack {
            CircleButtonView(.init(isContain ? .heartFill : .heart, action: {
                if isContain {
                    isLikedPray = false
                } else {
                    isLikedPray = true
                }
            }))

            Spacer()
            CircleButtonView(.init(.share, action: {
                PrayShareManager.shared.sharePrayer(model)

            }))
                
        }
    }
}

