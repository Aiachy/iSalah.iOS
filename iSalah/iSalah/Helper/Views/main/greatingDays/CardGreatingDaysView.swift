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
            .frame(width: size9, height: dh(0.2))
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
            VStack(alignment: .leading, spacing: 10) {
                /// Titles
                Text(model.name)
                    .font(FontHandler.setNewYorkFont(weight: .bold, size: .S))
                    .lineLimit(2)
                    .scaledToFill()
                
                /// Date
                Text(model.date.toFormatted("dd MMMM yyyy"))
                    .font(FontHandler.setNewYorkFont(weight: .bold, size: .xS))
                    .foregroundStyle(ColorHandler.getColor(salah, for: .shadow))
                Spacer()
            }
            .frame(width: dw(0.46),alignment: .leading)
            .padding(.vertical,5)
        }
        .frame(width: dw(0.49), height: dh(0.13), alignment: .leading)
    }
}
