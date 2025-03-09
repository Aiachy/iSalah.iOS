//
//  OnboardingViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    
    @Published var userCurrentLocation: LocationInfo? = nil
    @Published var isOnbActive: Bool
    @Published var selectedModelId: Int
    
    var cancelBag = Set<AnyCancellable>()
    private let coordinator: GeneralCoordinatorPresenter
    private let locationManager = LocationManager()

    init(userCurrentLocation: LocationInfo? = nil,
         isOnbActive: Bool = false,
         selectedModelId: Int = 0,
         coordinator: GeneralCoordinatorPresenter) {
        self.userCurrentLocation = userCurrentLocation
        self.isOnbActive = isOnbActive
        self.selectedModelId = selectedModelId
        
        self.coordinator = coordinator
        listenSelectedModelId()
    }
    
}
//MARK: Handler
extension OnboardingViewModel {
    
    func makeOnboarding() -> [OnboardingModel] {
        [
            .init(
                id: 0,
                title: "With You Every\nStep of the Way",
                description: "Your smart Islamic assistant is now ready. Specially designed for all your needs: prayer times, Quran readings, prayer reminders, and qibla compass.",
                button: "Ready",
                image: .onb1,
                action: { [self] in
                    isOnbActive = false
                    NotificationManager.shared.requestAuthorization { _ in }
                    nextOnbPage()
                }
            ),
            .init(
                id: 1,
                title: "Guidance Compass",
                description: "Could you please share your location so that we can calculate prayer times with precision and provide religious information specific to your area?",
                button: "Continue",
                image: .onb2,
                action: { [self] in
                    nextOnbPage()
                    getUserLocation() 
                }
            ),
            .init(
                id: 2,
                title: "Your Personal Experience",
                description: "Would you like to share your gender for personalized religious content? This helps us tailor recommendations for hijab, prayers, and other Islamic practices.",
                button: "",
                image: .onb3,
                action: { [self] in
                    coordinator.navigate(to: .main)
                    onboardingFinished()
                }
            )
            
        ]
    }
    
    func nextOnbPage() {
        selectedModelId += 1
    }
    
    private func onboardingFinished() {
        UserDefaults.standard.set(true, forKey: "onboardingFinished")
    }
    
    private func listenSelectedModelId() {
        $selectedModelId
            .receive(on: DispatchQueue.main)
            .sink { [self] modelId in
                withAnimation(.easeInOut) {
                    isOnbActive = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        self.isOnbActive = true
                    }
                }
            }
            .store(in: &cancelBag)
    }
    
}

extension OnboardingViewModel {
    
    private func getUserLocation() {
        print("iSalah: OnboardingViewModel - Started LocationManager ")
        locationManager.getUserLocation { [weak self] result in
            guard let self = self else { return }
            print("iSalah: OnboardingViewModel - Start getting user location")
            DispatchQueue.main.async {
                switch result {
                case .success(let locationInfo):
                    self.userCurrentLocation = locationInfo
                    print("iSalah: OnboardingViewModel - Successfully get user location")

                case .failure(let error):
                    print("iSalah: OnboardingViewModel - Failed to get user location Error: \(error)")
                }
            }
        }
    }
    
}
