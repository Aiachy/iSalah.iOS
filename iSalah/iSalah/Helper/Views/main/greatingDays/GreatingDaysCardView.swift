//
//  GreatingDaysCardView.swift
//  iSalah
//
//  Created by Mert Türedü on 9.03.2025.
//

import SwiftUI

struct GreatingDaysCardView: View {
    
    @EnvironmentObject var salah: iSalahState
    
    let models: [GreatingDaysModel]
    let action: () -> ()
    
    init (
        _ models: [GreatingDaysModel],
        action: @escaping () -> ()
    ) {
        self.models = models
        self.action = action
    }
    
    var body: some View {
        backgroundView
            .overlay(alignment: .center) {
                VStack {
                    headerView
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(models, id: \.id) { model in
                                makeCards(model)
                            }
                            
                        }
                        .padding(.leading)
                    }
                }
            }
            .onTapGesture {
                action()
            }
    }
}

#Preview {
    ZStack {
        let x =  Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 30))!

        BackgroundView()
        GreatingDaysCardView(GreatingDaysData.getDaysFor2025()){ }
    }
    .environmentObject(mockSalah)
}

private extension GreatingDaysCardView  {
    
    var backgroundView: some View {
        RoundedRectangle(cornerRadius: 16)
            .foregroundStyle(ColorHandler.getColor(salah, for: .islamicAlt))
            .frame(width: size9, height: dh(0.18))
    }
    
    var headerView: some View {
        HStack {
            Text("Greating Days")
                .font(FontHandler.setNewYorkFont(weight: .semibold , size: .s))
            Spacer()
            Text("See all")
                .font(FontHandler.setNewYorkFont(weight: .semibold , size: .xs))
                .underline()
        }
        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
        .padding(.horizontal)
    }
    
    func makeCards(_ model: GreatingDaysModel) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
            VStack(alignment: .leading) {
                Text(model.name)
                    .font(FontHandler.setNewYorkFont(weight: .bold, size: .m))
                Spacer()
                HStack {
                    VStack(alignment: .leading) {
                        Text(model.date.toFormatted("dd MMMM yyyy"))
                        Text(model.date.toFormattedHijri())
                    }
                    Spacer()
                        
                }
            }
            .font(FontHandler.setNewYorkFont(weight: .bold, size: .xs))
            .foregroundStyle(ColorHandler.getColor(salah, for: .shadow))
            .frame(width: dw(0.46),alignment: .leading)
        }
        .frame(width: dw(0.49), height: dh(0.115), alignment: .leading)
    }
}
