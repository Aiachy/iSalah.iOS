//
//  SettingsView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI
//MARK: View
struct SettingsView: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: SettingsViewModel
    
    init(_ coordinator: SettingsCoordinatorPresenter ) {
        _vm = StateObject(wrappedValue: SettingsViewModel(coordinator: coordinator))
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack(spacing: 5) {
                MainHeaderView(
                    .constant(true),
                    navToCompass: vm.navigationToCompass
                )
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 15) {
                        /// Subscribe
                        if !salah.user.checkIsPremium() {
                            makeSettingsButton("Subscribe", icon: .subscribe, action: vm.openPaywall)
                        }
                        /// Profile
                        makeSettingsButton("Profile", icon: .profile, action: vm.navToProfile)
                        /// Themes
                        makeSettingsButton("Themes", icon: .theme, action: vm.navToTheme)
                        /// Accessi
                        makeSettingsButton("Accessibility", icon: .accessibility, action: vm.navToAccessibility)
                        /// Terms of privacy
                        makeSettingsButton("Terms of Use and Privacy Policy", icon: .privacyAndTerms, action: vm.openTermsAndPrivacy)
                        /// Notify
                        makeSettingsButton("Notifications", icon: .notification, action: vm.navToNotifications)
                        /// Contact
                        makeSettingsButton("Contact Us", icon: .contact, action: {
                            vm.makeMail(salah.user)
                        })
                        /// Rate Us
                        if !vm.rateManager.hasUserReviewed() {
                            makeSettingsButton("Rate Us", icon: .star, action: vm.rateUs)
                        }
                        
                        makeSettingsButton("Rate Us", icon: .star, action: vm.rateUs)
                            .opacity(0.001)
                            .disabled(true)
                    }
                    .padding(.top)
                }
            }
        }
        .sheet(isPresented: $vm.isOpenPrivacyAndTerms) {
            PrivacyAndPolicyView()
                .modifier(SheetModifier(borderC: .oneTrue, 0.98))
        }
        .fullScreenCover(isPresented: $vm.isOpenPaywall) {
            PaywallView($vm.isOpenPaywall)
        }
    }
}
//MARK: Preview
#Preview {
    ZStack {
        BackgroundView()
        SettingsView(.init())
    }
    .environmentObject(mockSalah)
}
//MARK: Views
private extension SettingsView {

    func makeSettingsButton(_ title: LocalizedStringKey, icon: ImageHelper.icon, action: @escaping () -> ()) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(ColorHandler.getColor(salah, for: .islamicAlt))
            RoundedRectangle(cornerRadius: 10)
                .stroke(ColorHandler.getColor(salah, for: .gold))
            
            HStack(spacing: 15) {
                /// Icon
                ImageHandler.getIcon(salah, image: icon)
                    .scaledToFit()
                    .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                    .frame(width: dw(0.05))
                /// Title
                Text(title)
                    .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                    .font(FontHandler.setDubaiFont(weight: .bold, size: .m))
                Spacer()
            }
            .padding(.horizontal)
        }
        .frame(width: size9, height: dh(0.084))
        .onTapGesture {
            withAnimation(.linear) {
                action()
            }
        }
    }
    
}
