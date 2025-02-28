//
//  ProfileView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: ProfileViewModel
    
    init(_ coordinator: SettingsCoordinatorPresenter ) {
        _vm = StateObject(wrappedValue: ProfileViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack {
                SettingsHeaderView("Profile", back: vm.makeBackButton)
                HStack(alignment: .center) {
                    Text("Gender")
                        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                        .font(FontHandler.setDubaiFont(weight: .bold, size: .l))
                    Spacer()
                    HStack(spacing: 20) {
                        let gender = salah.user.info.gender
                        
                        makeGenderButtonView(.female, icon: .female, isSelected: gender == "Female")
                            .onTapGesture {
                                salah.user.info.gender = "Female"
                            }
                        makeGenderButtonView(.male, icon: .male, isSelected: gender == "Male")
                            .onTapGesture {
                                salah.user.info.gender = "Male"
                            }
                    }
                    .frame(height: dh(0.06))
                    
                }
                Spacer()
            }
            .frame(width: size9)
        }
    }
}

#Preview {
    ProfileView(.init())
        .environmentObject(mockSalah)
}

private extension ProfileView {
    func makeGenderButtonView(_ circleColor: ColorHelper.original, icon: ImageHelper.icon, isSelected: Bool) -> some View {
        ZStack {
            Circle()
                .stroke(ColorHandler.getColor(salah, for: isSelected ? .gold : .light))
            Circle()
                .fill(ColorHandler.getColor(salah, for: circleColor))
                .padding(0.5)
            ImageHandler.getIcon(salah, image: icon)
                .scaledToFit()
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .padding(15)
        }
        
    }
}
