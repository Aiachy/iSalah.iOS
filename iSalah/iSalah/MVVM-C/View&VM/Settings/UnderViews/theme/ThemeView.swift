//
//  ThemeView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct ThemeView: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: ThemeViewModel
    
    init(
        _ coordinator: SettingsCoordinatorPresenter
    ) {
        _vm = StateObject(
            wrappedValue: ThemeViewModel(coordinator: coordinator)
        )
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                SettingsHeaderView("Themes", back: vm.makeBackButton)
                VStack(spacing: 30) {
                    medineThemeRow
                    roseThemeRow
                    arabThemeRow
                }
                Spacer()
            }
        }
    }
}

#Preview {
 
    ThemeView(.init())
        .environmentObject(mockSalah)
        
}

extension ThemeView {
    
    var medineThemeRow: some View {
        VStack {
            /// Colors
            HStack {
                ForEach(ColorHelper.original.allCases.filter {
                    !["oneTrue", "dark", "female", "male"].contains($0.rawValue)
                }, id: \.self) { color in
                    makeRowForThemeView(Color(color.rawValue))
                }
            }
            /// Title
            Text("Medina Evening")
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .font(FontHandler.setNewYorkFont(weight: .bold, size: .xl))
                .background(alignment: .bottom) {
                    ColorHandler.getColor(salah, for: .gold)
                        .frame(height: 1)
                        .offset(y: 5)
                        .opacity(salah.user.appInfo.theme == "Medina Evening" ? 1 : 0 )
                }
        }
        .onTapGesture {
            salah.user.appInfo.theme = "Medina Evening"
        }
    }
    
    var roseThemeRow: some View {
        VStack {
            /// Colors
            HStack {
                ForEach(ColorHelper.rose.allCases.filter {
                    !["oneTrue", "dark", "female", "male"].contains($0.rawValue)
                }, id: \.self) { color in
                    makeRowForThemeView(Color(color.rawValue))
                }
            }
            
            /// Title
            Text("Half Rose")
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .font(FontHandler.setNewYorkFont(weight: .bold, size: .xl))
                .background(alignment: .bottom) {
                    ColorHandler.getColor(salah, for: .gold)
                        .frame(height: 1)
                        .offset(y: 5)
                        .opacity(salah.user.appInfo.theme == "Half Rose" ? 1 : 0 )
                }
        }
        .onTapGesture {
            salah.user.appInfo.theme = "Half Rose"
        }
    }
    
    var arabThemeRow: some View {
        VStack {
            /// Colors
            HStack {
                ForEach(ColorHelper.arab.allCases.filter {
                    !["oneTrue", "dark", "female", "male"].contains($0.rawValue)
                }, id: \.self) { color in
                    makeRowForThemeView(Color(color.rawValue))
                }
            }
            
            /// Title
            Text("Arabian Desert")
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .font(FontHandler.setNewYorkFont(weight: .bold, size: .xl))
                .background(alignment: .bottom) {
                    ColorHandler.getColor(salah, for: .gold)
                        .frame(height: 1)
                        .offset(y: 5)
                        .opacity(salah.user.appInfo.theme == "Arab Desert" ? 1 : 0 )
                }
        }
        .onTapGesture {
            salah.user.appInfo.theme = "Arab Desert"
        }
    }
    
    
    
    func makeRowForThemeView(_ color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .stroke(ColorHandler.getColor(salah, for: .light))
            RoundedRectangle(cornerRadius: 10)
                .fill(color)
        }
        .frame(width: dw(0.135), height: dh(0.2))
    }
    
}
