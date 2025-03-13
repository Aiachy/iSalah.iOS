//
//  CardGreatingDaysView.swift
//  iSalah
//
//  Created by Mert Türedü on 9.03.2025.
//

import SwiftUI
//MARK: View
struct CardGreatingDaysView: View {
    
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
                    /// Header
                    headerView
                    /// Content Cards
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
            .onTapGesture { action() }
    }
}
//MARK: Preview
#Preview {
    ZStack {
        let x =  Calendar.current.date(
            from: DateComponents(year: 2025, month: 2, day: 30)
        )!

        BackgroundView()
        CardGreatingDaysView(GreatingDaysData.getDaysFor2025()){ }
    }
    .environmentObject(mockSalah)
}
//MARK: Views
private extension CardGreatingDaysView  {
    
    var backgroundView: some View {
        let corner = 8.0
        
        return ZStack {
            RoundedRectangle(cornerRadius: corner)
                .foregroundStyle(ColorHandler.getColor(salah, for: .islamicAlt))
            RoundedRectangle(cornerRadius: corner)
                .stroke(ColorHandler.getColor(salah, for: .islam))
        }
            .frame(width: size9, height: dh(0.17))
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
                .opacity(0.95)
            VStack(alignment: .leading, spacing: 10) {
                /// Titles
                Text(model.name)
                    .font(FontHandler.setNewYorkFont(weight: .bold, size: .S))
                
                /// Date
                Text(model.date.toFormatted("dd MMMM yyyy"))
                    .font(FontHandler.setNewYorkFont(weight: .bold, size: .xS))
                Spacer()
            }
            .frame(width: dw(0.46),alignment: .leading)
            .foregroundStyle(ColorHandler.getColor(salah, for: .shadow))
            .padding(.vertical,5)
        }
        .frame(width: dw(0.49), height: dh(0.11), alignment: .leading)
        .overlay(alignment: .bottomTrailing) { makeCardCounterView(model) }
    }
    
    func makeCardCounterView(_ model: GreatingDaysModel) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                
            RoundedRectangle(cornerRadius: 4)
                .stroke(ColorHandler.getColor(salah, for: .shadow))
                
            VStack(alignment: .center, spacing: 0) {
                Text(model.untilDay)
                    .font(FontHandler.setNewYorkFont(weight: .black, size: .xs))
                Text("Day")
                    .font(FontHandler.setDubaiFont(weight: .medium, size: .xxs))
            }
            .foregroundStyle(ColorHandler.getColor(salah, for: .shadow))
                
        }
        .frame(width: dw(0.07), height: dh(0.04),alignment: .center)
        .padding(5)
    }
}
