//
//  OnboardingView.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import SwiftUI

struct OnboardingView: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: OnboardingViewModel
    
    init(_ coordinator: GeneralCoordinatorPresenter = .init()) {
        _vm = StateObject(
            wrappedValue: OnboardingViewModel(coordinator: coordinator)
        )
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $vm.selectedModelId) {
                makeOnboardingView(
                    vm
                        .makeOnboarding()
                        .first(where: { $0.id == vm.selectedModelId })!
                )
            }
        }
        .onChange(of: vm.userCurrentLocation != nil) { newValue in
            if let location = vm.userCurrentLocation, let city = location.city, let country = location.country {
                    let userLocation = LocationSuggestion(
                        country: country,
                        city: city,
                        district: location.district ?? "",
                        coordinate: location.coordinate
                    )
                print("iSalah: OnboardingView - userLocation: \(userLocation)")
                salah.user.location = userLocation
            }
        }
    }
}
//MARK: Preview
#Preview {
    OnboardingView()
        .environmentObject(iSalahState())
}
//MARK: Views
private extension OnboardingView {
    func makeOnboardingView(_ model: OnboardingModel) -> some View {
        let onbAct = vm.isOnbActive
        let radius = dw(1) / 7
        
        return ZStack {
            /// Background
            ImageHandler.getMassive(salah, image: model.image)
                .cornerRadius(dw(1) / 6.5)
                .padding(onbAct ? -15 : -5)
            /// Content
            ZStack {
                BackgroundView()
                    .opacity(0.4)

                RoundedRectangle(cornerRadius: radius)
                    .stroke(ColorHandler.getColor(salah, for: .gold))
                    
                makeOnboardingCircleView(model)
            }
            .opacity(onbAct ? 1 : 0)
        }
        .animation(.easeInOut, value: onbAct)
        .ignoresSafeArea()
    }
    
    func makeOnboardingCircleView(_ model: OnboardingModel) -> some View {
        ZStack {
            circleBackgroundView
            VStack {
                makeCircleTitleAndDescription(model)
                circleStarLineView
                Spacer()
                if vm.selectedModelId == 2 {
                    /// Gender Buttons
                    HStack(spacing: 60) {
                        makeGenderButtonView(.female, icon: .female)
                            .onTapGesture {
                                model.action()
                                salah.user.info.gender = "Female"
                            }
                        makeGenderButtonView(.male, icon: .male)
                            .onTapGesture {
                                model.action()
                                salah.user.info.gender = "Male"
                            }
                    }
                    .frame(height: dh(0.08))
                } else {
                    /// Normal Button
                    RoundedButtonView(model.button, action: model.action)
                }
                Spacer()
            }
            .frame(height: dh(0.5))
            .multilineTextAlignment(.center)
            
        }
        .frame(width: dw(0.96))
    }
    
    /// Circle Background
    var circleBackgroundView: some View {
        ZStack {
            /// Stroke
            Circle()
                .stroke(
                    ColorHandler.getColor(salah, for: .gold).opacity(0.4),
                    lineWidth: 3
                )
            /// Background
            Circle()
                .foregroundStyle(
                    ColorHandler.getColor(salah, for: .islamic)
                )
            
            ImageHandler.getMassive(salah, image: .onbCircle)
                .scaledToFit()
                .opacity(0.2)
                .padding(50)
            
        }
    }
    
    /// Circle Title And Description
    func makeCircleTitleAndDescription(_ model: OnboardingModel) -> some View {
        VStack(spacing: 0) {
            /// Title
            Text(model.title)
                .foregroundStyle(ColorHandler.getColor(salah, for: .horizon))
                .font(FontHandler.setDubaiFont(weight: .bold, size: .l))
                .frame(width: dw(0.6))
                .padding(.bottom)
            /// Decription
            Text(model.description)
                .foregroundStyle(ColorHandler.getColor(salah, for: .light))
                .font(FontHandler.setDubaiFont(weight: .regular, size: .xs))
                .padding(.horizontal)
                
        }
        .frame(height: dh(0.235))
        .padding(.horizontal,10)
    }
    
    /// Circle Star Line View
    var circleStarLineView: some View {
        HStack {
            Rectangle()
                .frame(width: dw(0.35),height: 1)
            ImageHandler.getIcon(salah, image: .star)
                .scaledToFit()
                .frame(width: dw(0.07))
            Rectangle()
                .frame(width: dw(0.35),height: 1)
        }
        .foregroundStyle(ColorHandler.getColor(salah, for: .light))
    }
    
}
//MARK: Buttons
private extension OnboardingView {
    /// Circel Gender Button
    func makeGenderButtonView(_ circleColor: ColorHelper.original, icon: ImageHelper.icon) -> some View {
        ZStack {
            Circle()
                .stroke(ColorHandler.getColor(salah, for: .gold))
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
