//
//  OnboardingViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    
    @Published var isOnbActive: Bool
    @Published var isLocationSheetActive: Bool
    @Published var selectedModelId: Int
    
    var cancelBag = Set<AnyCancellable>()
    let coordinator: GeneralCoordinatorPresenter
    
    init(isOnbActive: Bool = false,
         isLocationSheetActive: Bool = false,
         selectedModelId: Int = 0,
         coordinator: GeneralCoordinatorPresenter) {
        self.isOnbActive = isOnbActive
        self.isLocationSheetActive = isLocationSheetActive
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
                title: "With You Every Step of the Way",
                description: "Your smart assistant that makes yourIslamic life easier is now ready.It is specially designed for all your needs,from prayer times to Quran readings, from prayer reminders to qibla compass.",
                button: "Ready",
                image: .onb1,
                action: { [self] in
                    isOnbActive = false
                    nextOnbPage()
                }
            ),
            .init(
                id: 1,
                title: "Guidance Compass",
                description: "Could you please share your location so that we can calculate prayer times with precision and provide religious information specific to your area?",
                button: "Find Location",
                image: .onb2,
                action: { [self] in
                    isLocationSheetActive.toggle()
                }
            ),
            .init(
                id: 2,
                title: "Your Personal Experience",
                description: "Could you please specify your gender so that we can provide you with personalized content and religious information? This information will help us organize special recommendations for your hijab, prayers and other religious practices.",
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
