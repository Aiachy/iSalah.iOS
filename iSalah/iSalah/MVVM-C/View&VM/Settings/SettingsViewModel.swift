//
//  SettingsViewModel.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import UIKit

class SettingsViewModel: ObservableObject {
    
    @Published var isOpenPaywall: Bool
    @Published var isOpenPrivacyAndTerms: Bool
    
    let coordinator: SettingsCoordinatorPresenter
    let rateManager = RateUsManager.shared
    init(isOpenPaywall: Bool = false,
         isOpenPrivacyAndTerms: Bool = false,
         coordinator: SettingsCoordinatorPresenter) {
        self.isOpenPaywall = isOpenPaywall
        self.isOpenPrivacyAndTerms = isOpenPrivacyAndTerms
        self.coordinator = coordinator
    }
    
}

extension SettingsViewModel {
    
    func navigationToCompass() {
        
    }
    
    func openPaywall() {
        isOpenPaywall.toggle()
    }
    
    func navToProfile() {
        coordinator.navigate(to: .profile)
    }
    
    func navToTheme() {
        coordinator.navigate(to: .theme)
    }
    
    func navToAccessibility() {
        coordinator.navigate(to: .accessibility)
    }
    
    func openTermsAndPrivacy() {
        isOpenPrivacyAndTerms.toggle()
    }
    
    func navToNotifications() {
        coordinator.navigate(to: .notifications)
    }
    
    func makeMail(_ model: UserModel) {
            // Configure email components
            let recipient = "nomotetes.onetrue@icloud.com"
            let subject = "AISalah App Problem/Asking"
            
            // Build the body content with user information
            var bodyContent = "User Information:\n"
            bodyContent += "ID: \(model.id ?? "Not available")\n"
            bodyContent += "Premium Status: \(model.info.isPremium ? "Premium" : "Free")\n"
            
            if let premiumType = model.info.premiumType {
                bodyContent += "Premium Type: \(premiumType)\n"
            }
            
            if let gender = model.info.gender {
                bodyContent += "Gender: \(gender)\n"
            }
            
            bodyContent += "Theme: \(model.appInfo.theme)\n"
            
            if let location = model.location {
                bodyContent += "Location: \(location.formattedLocation)\n"
            }
            
            // URL encode the components for the mailto URL
            let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let encodedBody = bodyContent.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
            // Create the mailto URL
            let mailtoURLString = "mailto:\(recipient)?subject=\(encodedSubject)&body=\(encodedBody)"
            
            if let mailtoURL = URL(string: mailtoURLString), UIApplication.shared.canOpenURL(mailtoURL) {
                UIApplication.shared.open(mailtoURL, options: [:], completionHandler: nil)
            }
        }
    
    func rateUs() {
        rateManager.promptForReviewNow()
    }
}
