//
//  GreatingDayInsightColumnView.swift
//  iSalah
//
//  Created by Mert Türedü on 8.03.2025.
//

import SwiftUI

struct GreatingDayInsightColumnView: View {
    
    @EnvironmentObject var salah: iSalahState
    let model: GreatingDaysModel
    
    init(_ model: GreatingDaysModel) {
        self.model = model
    }
    
    var body: some View {
        backgroundView
            .overlay(alignment: .center) {
                VStack(alignment: .center) {
                    titleView
                    dateAndHicriDateView
                    Spacer()
                    counterTimeView
                }
                .padding(.vertical,5)
            }
            .opacity(model.date.daysUntil() < 0 ? 0.7 : 1)
    }
}

#Preview {
    ZStack {
    let x =  Calendar.current.date(from: DateComponents(year: 2025, month: 2, day: 30))!
        BackgroundView()
        GreatingDayInsightColumnView(
            .init(id: 1, name: "Ramadan Greating", date: x)
        )
    }
    .environmentObject(mockSalah)
}

extension GreatingDayInsightColumnView {
    
    private var backgroundView: some View {
        ZStack {
            /// background
            RoundedRectangle(cornerRadius: 10)
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .shadow(
                    color: ColorHandler
                        .getColor(salah, for: .light)
                        .opacity(0.25),
                    radius: 5,
                    y: 5
                )
            /// Stroke
            RoundedRectangle(cornerRadius: 10)
                .stroke(
                    ColorHandler.getColor(salah, for: .shadow),
                    lineWidth: 1
                )
        }
        .frame(width: size9, height: dh(0.12))
    }
    
    private var titleView: some View {
        Text(model.name)
            .foregroundStyle(ColorHandler.getColor(salah, for: .shadow))
            .font(FontHandler.setNewYorkFont(weight: .bold,size: .m))
    }
    
    private var dateAndHicriDateView: some View {
        HStack(alignment: .center) {
            Text(model.date.toFormatted())
                .frame(width: dw(0.35))
                
            Text(model.date.toFormattedHijri())
                .frame(width: dw(0.35))
        }
        .foregroundStyle(ColorHandler.getColor(salah, for: .shadow))
        .font(FontHandler.setNewYorkFont(weight: .medium, size: .xs))
    }
    
    private var counterTimeView: some View {
        let untilDays = model.date.daysUntil()
        let isNegative = untilDays < 0
        
        return Text(abs(untilDays).description + " " + "Day \(isNegative ? "Before" : "After")")
            .foregroundStyle(ColorHandler.getColor(salah, for: .shadow))
            .font(FontHandler.setNewYorkFont(weight: .medium, size: .xs))
    }
}

