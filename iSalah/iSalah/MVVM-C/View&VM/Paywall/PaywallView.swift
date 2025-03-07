//
//  PaywallView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct PaywallView: View {
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: PaywallViewModel
    @Binding var isAppear: Bool
    
    init(_ isAppear: Binding<Bool>) {
        _vm = StateObject(wrappedValue: PaywallViewModel())
        _isAppear = isAppear
    }
    
    var body: some View {
        ZStack {
            backgroundView
            VStack {
                Spacer()
                makeElementView("Remove all ads and use the app with an ad-free, peaceful experience.")
                    
                makeElementView("Get unlimited access and enjoy a soulful experience with special themes.")
                    .padding(.vertical,20)
                    .padding(.bottom,40)
                buyButtonView
                
                restoreButtonView
            }
        }
        .overlay(alignment: .topLeading, content: { cancelButtonView })
        .overlay { if vm.isLoading { loadingView } }
        .environmentObject(salah)
    }
}

#Preview {
    PaywallView(.constant(false))
        .environmentObject(mockSalah)
}

private extension PaywallView {
    
    var backgroundView: some View {
        let radius = dw(1) / 7

        return ZStack {
            ImageHandler.getMassive(salah, image: .paywall)
                .scaleEffect(vm.isAppearPaywall ? 1.1 : 1)
                .animation(.linear(duration: 0.5), value: vm.isAppearPaywall)
            BackgroundView()
                .opacity(vm.isAppearPaywall ? 0.3 : 0)
                .animation(.easeIn(duration: 2), value: vm.isAppearPaywall)
            RoundedRectangle(cornerRadius: radius)
                .stroke(ColorHandler.getColor(salah, for: .gold))
        }
        .ignoresSafeArea()
    }
    
    func makeElementView(_ text: LocalizedStringKey) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(ColorHandler.getColor(salah, for: .light))
                .padding(.vertical, -10)
            Text(text)
                .foregroundStyle(ColorHandler.getColor(salah, for: .shadow))
                .font(FontHandler.setDubaiFont(weight: .bold, size: .s))
                .multilineTextAlignment(.center)
                .lineSpacing(-5)
                .padding(.horizontal)
        }
            .frame(width: size9, height: dh(0.08))
    }
    
    var buyButtonView: some View {
        Button(action: {
            vm.purchasePackage { isPurchasing in
                if isPurchasing {
                    salah.user.info.isPremium = true
                    isAppear = false
                    dismiss()
                }
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .stroke(ColorHandler.getColor(salah, for: .gold))
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(ColorHandler.getColor(salah, for: .islamicAlt))
                
                Text(vm.fullSubscriptionText + " " + "with year subscription")
                    .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                    .font(FontHandler.setDubaiFont(weight: .bold, size: .l))
            }
            .frame(width: size9, height: dh(0.08))
        }
        .disabled(vm.isLoading || vm.currentPackage == nil)
    }
    
    var restoreButtonView: some View {
        Button {
            vm.restorePurchases { isRestored in
                if isRestored {
                    print("PaywallView: Purchases Restored Successfully")
                    salah.user.info.isPremium = true
                    dismiss()
                } else {
                    print("PaywallView: Failed To Restore Purchases")
                }
                
            }
        } label: {
            Text("Restore Purchases")
                .font(FontHandler.setDubaiFont(weight: .regular, size: .s))
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(ColorHandler.getColor(salah, for: .islamic))
                        .padding(.horizontal, -8)
                }
        }
    }
    
    var cancelButtonView: some View {
        ImageHandler.getIcon(salah, image: .cancel)
            .scaledToFit()
            .foregroundStyle(ColorHandler.getColor(salah, for: .light))
            .opacity(0.4)
            .frame(width: dw(0.05))
            .padding(.leading)
            .onTapGesture {
                print("PaywallView: Dismissed View By User")
                dismiss()
            }
    }
    
    var loadingView: some View {
        ZStack {
            Color.black.opacity(0.5)
            VStack {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(ColorHandler.getColor(salah, for: .light))
                
                Text("Please wait...")
                    .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                    .font(FontHandler.setDubaiFont(weight: .medium, size: .s))
                    .padding(.top, 12)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(ColorHandler.getColor(salah, for: .islamicAlt).opacity(0.9))
            )
        }
        .ignoresSafeArea()
    }
}
