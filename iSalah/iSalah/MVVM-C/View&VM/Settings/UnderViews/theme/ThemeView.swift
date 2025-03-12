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
                ScrollView(.vertical,showsIndicators: false) {
                    VStack(spacing: 30) {
                        medineThemeRow
                        roseThemeRow
                        arabThemeRow
                    }
                    .padding(.top)
                }
                Spacer()
            }
        }
        .fullScreenCover(isPresented: $vm.isPaywallAppear) {
            PaywallView($vm.isPaywallAppear)
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
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ColorHelper.original.allCases.filter {
                        !["oneTrue", "dark", "female", "male"].contains($0.rawValue)
                    }, id: \.self) { color in
                        makeRowForThemeView(Color(color.rawValue))
                    }
                }
                .padding(.vertical)
                .padding(.leading)
            }
                
            /// Title
            Text("Medina Evening")
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .font(FontHandler.setNewYorkFont(weight: .bold, size: .xl))
                .background(alignment: .bottom) {
                    ColorHandler.getColor(salah, for: .gold)
                        .frame(height: 1)
                        .offset(y: 5)
                        .opacity(checkIsSelectedTheme("Medina Evening"))
                }
        }
        .onTapGesture { makeSelectedTheme("Medina Evening", isPremium: false) }
    }
    
    var roseThemeRow: some View {
        VStack {
            /// Colors
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ColorHelper.rose.allCases.filter {
                        !["oneTrue", "dark", "female", "male"].contains($0.rawValue)
                    }, id: \.self) { color in
                        makeRowForThemeView(Color(color.rawValue))
                    }
                }
                .padding(.vertical)
                .padding(.leading)
            }
            
            /// Title
            VStack(spacing: 0){
                Text("Half Rose")
                    .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                    .font(FontHandler.setNewYorkFont(weight: .bold, size: .xl))
                    .background(alignment: .bottom) {
                        ColorHandler.getColor(salah, for: .gold)
                            .frame(height: 1)
                            .offset(y: 5)
                            .opacity(checkIsSelectedTheme("Half Rose"))
                    }
                makePremiumTitle()
            }
        }
        .onTapGesture { makeSelectedTheme("Half Rose") }
    }
    
    var arabThemeRow: some View {
        VStack {
            /// Colors
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ColorHelper.arab.allCases.filter {
                        !["oneTrue", "dark", "female", "male"].contains($0.rawValue)
                    }, id: \.self) { color in
                        makeRowForThemeView(Color(color.rawValue))
                    }
                }
                .padding(.vertical)
                .padding(.leading)
            }
            
            /// Title
            VStack(spacing: 0) {
                Text("Arabian Desert")
                    .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                    .font(FontHandler.setNewYorkFont(weight: .bold, size: .xl))
                    .background(alignment: .bottom) {
                        ColorHandler.getColor(salah, for: .gold)
                            .frame(height: 1)
                            .offset(y: 5)
                            .opacity(checkIsSelectedTheme("Arab Desert") )
                    }
                makePremiumTitle()
            }
        }
        .onTapGesture { makeSelectedTheme("Arab Desert") }
    }
    
    
    
    func makeRowForThemeView(_ color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .stroke(ColorHandler.getColor(salah, for: .light))
            RoundedRectangle(cornerRadius: 6)
                .fill(color)
        }
        .frame(width: dw(0.12), height: dh(0.23))
    }
    
}

private extension ThemeView {
    
    func checkIsSelectedTheme(_ themeTitle: String) -> Double {
        salah.user.appInfo.theme == themeTitle ? 1 : 0
    }
    
    func makeSelectedTheme(_ themeTitle: String, isPremium: Bool = true) {
        guard themeTitle != salah.user.appInfo.theme else { return }
        
        guard !isPremium || salah.user.checkIsPremium() else { vm.isPaywallAppear.toggle(); return }
        withAnimation(.linear) {
            salah.user.appInfo.theme = themeTitle
            UserDefaults.standard.set(themeTitle, forKey: themeIdKey)
        }
    }
    
    @ViewBuilder
    func makePremiumTitle() -> some View {
        if !salah.user.checkIsPremium() {
            Text("Premium")
                .foregroundStyle(ColorHandler.getColor(salah, for: .gold))
                .font(FontHandler.setNewYorkFont(weight: .bold, size: .s))
        }
    }
    
}
