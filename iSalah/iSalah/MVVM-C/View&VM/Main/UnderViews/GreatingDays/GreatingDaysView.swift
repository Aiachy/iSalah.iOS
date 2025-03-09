//
//  GreatingDaysView.swift
//  iSalah
//
//  Created by Mert Türedü on 28.02.2025.
//

import SwiftUI

struct GreatingDaysView: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: GreatingDaysViewModel
    
    init (
        _ coordinator: MainCoordinatorPresenter
    ) {
        _vm = StateObject(wrappedValue: GreatingDaysViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack(spacing: 16) {
                SettingsHeaderView("Blessed Days", back: vm.makeBackButton)
                
                yearSelectorView
                
                ScrollView(.vertical,showsIndicators: false) {
                    VStack(spacing: 16) {
                        if let selectedYearDays = vm.daysByYear[vm.selectedYear] {
                            ForEach(selectedYearDays) { day in
                                GreatingDayInsightColumnView(day)
                            }
                        } else {
                            noDataView
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            vm.loadData()
        }
    }
}

//MARK: Preview
#Preview {
    GreatingDaysView(.init())
        .environmentObject(mockSalah)
}

//MARK: Views
private extension GreatingDaysView {
    var yearSelectorView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(vm.availableYears, id: \.self) { year in
                    yearButtonView(for: year)
                }
            }
            .padding(.horizontal)
        }
        
    }
    
    func yearButtonView(for year: Int) -> some View {
        Button {
            vm.selectedYear = year
        } label: {
            Text(year.description)
                .font(FontHandler.setNewYorkFont(weight: .semibold, size: .s))
                .foregroundStyle(vm.selectedYear == year ?
                                 ColorHandler.getColor(salah, for: .shadow) :
                                    ColorHandler.getColor(salah, for: .light))
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background {
                    if vm.selectedYear == year {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(ColorHandler.getColor(salah, for: .light))
                            .shadow(
                                color: ColorHandler.getColor(salah, for: .light).opacity(0.3),
                                radius: 4, y: 2
                            )
                    }
                }
        }
    }
    
    var noDataView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 50))
                .foregroundStyle(ColorHandler.getColor(salah, for: .shadow))
            
            Text("No blessed days available for this year")
                .font(FontHandler.setNewYorkFont(weight: .medium, size: .s))
                .foregroundStyle(ColorHandler.getColor(salah, for: .shadow))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}
