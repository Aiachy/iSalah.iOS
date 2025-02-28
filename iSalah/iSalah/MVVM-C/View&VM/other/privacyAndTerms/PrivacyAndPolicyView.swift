//
//  PrivacyAndPolicyView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

//
//  PrivacyAndPolicyView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct PrivacyAndPolicyView: View {
    
    @EnvironmentObject var salah: iSalahState
    @StateObject var vm: PrivacyAndPolicyViewModel
    
    init() {
        _vm = StateObject(wrappedValue: PrivacyAndPolicyViewModel())
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            VStack(spacing: 15) {
                // Section Toggle Buttons
                HStack(spacing: 15) {
                    makeSectionButtonView("Privacy Policy", section: 0)
                    makeSectionButtonView("Terms Usage", section: 1)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Content
                ScrollView(.vertical, showsIndicators: true) {
                    VStack(alignment: .center, spacing: 15) {
                        Text(vm.section == 0 ? "Privacy Policy" : "Terms of Usage")
                            .foregroundColor(ColorHandler.getColor(salah, for: .light))
                            .font(FontHandler.setDubaiFont(weight: .bold, size: .l))
                            .padding(.bottom, 5)
                        
                        if vm.section == 0 {
                            privacyPolicyContent
                        } else {
                            termsOfUsageContent
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.top, 5)
            }
            .padding(.vertical)
        }
    }
}

//MARK: Preview
#Preview {
    PrivacyAndPolicyView()
        .environmentObject(mockSalah)
}

//MARK: Views
private extension PrivacyAndPolicyView {
    func makeSectionButtonView(_ title: LocalizedStringKey, section: Int) -> some View {
        let isSelected = vm.section == section
        
        return Button(action: {
                vm.section = section
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill( ColorHandler.getColor(salah, for: .islamicAlt))
                RoundedRectangle(cornerRadius: 10)
                    .stroke(ColorHandler.getColor(salah, for: isSelected ? .gold : .light), lineWidth: 1.5)
                
                /// Title
                Text(title)
                    .foregroundColor(isSelected
                                     ? ColorHandler.getColor(salah, for: .gold)
                                     : ColorHandler.getColor(salah, for: .light))
                    .font(FontHandler.setDubaiFont(weight: .medium, size: .m))
                    .padding(.horizontal, 10)
            }
            .animation(.easeInOut, value: isSelected)
        }
        .frame(width: dw(0.3), height: dh(0.044))
    }
}

//MARK: Privacy And Policy
private extension PrivacyAndPolicyView {
    // Privacy Policy Content https://www.termsfeed.com/live/4665ca12-d263-4515-93dc-e7afd942d969
    private var privacyPolicyContent: some View {
        VStack(alignment: .leading, spacing: 15) {
            Group {
                Text("Last updated: February 27, 2025")
                    .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))
                    .font(FontHandler.setDubaiFont(weight: .regular))
                
                Text("This Privacy Policy describes Our policies and procedures on the collection, use and disclosure of Your information when You use the Service and tells You about Your privacy rights and how the law protects You.")
                    .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))
                    .font(FontHandler.setDubaiFont(weight: .regular))
                
                Text("We use Your Personal data to provide and improve the Service. By using the Service, You agree to the collection and use of information in accordance with this Privacy Policy.")
                    .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))
                    .font(FontHandler.setDubaiFont(weight: .regular))
                
                sectionHeader("Interpretation and Definitions")
                
                subSectionHeader("Interpretation")
                
                Text("The words of which the initial letter is capitalized have meanings defined under the following conditions. The following definitions shall have the same meaning regardless of whether they appear in singular or in plural.")
                    .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))
                    .font(FontHandler.setDubaiFont(weight: .regular))
                
                subSectionHeader("Definitions")
                
                Text("For the purposes of this Privacy Policy:")
                    .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))
                    .font(FontHandler.setDubaiFont(weight: .regular))
                
                bulletPoint("Account", "means a unique account created for You to access our Service or parts of our Service.")
                bulletPoint("Affiliate", "means an entity that controls, is controlled by or is under common control with a party, where \"control\" means ownership of 50% or more of the shares, equity interest or other securities entitled to vote for election of directors or other managing authority.")
                bulletPoint("Application", "refers to AISalah, the software program provided by the Company.")
                bulletPoint("Company", "refers to AISalah.")
                bulletPoint("Country", "refers to: Turkey")
            }
            
            Group {
                bulletPoint("Device", "means any device that can access the Service such as a computer, a cellphone or a digital tablet.")
                bulletPoint("Personal Data", "is any information that relates to an identified or identifiable individual.")
                bulletPoint("Service", "refers to the Application.")
                bulletPoint("Service Provider", "means any natural or legal person who processes the data on behalf of the Company.")
                
                sectionHeader("Collecting and Using Your Personal Data")
                
                subSectionHeader("Types of Data Collected")
                
                bulletHeader("Personal Data")
                
                Text("While using Our Service, We may ask You to provide Us with certain personally identifiable information that can be used to contact or identify You. Personally identifiable information may include, but is not limited to:")
                    .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))
                    .font(FontHandler.setDubaiFont(weight: .regular))
                
                bulletList([
                    "Email address",
                    "First name and last name",
                    "Phone number",
                    "Address, State, Province, ZIP/Postal code, City",
                    "Usage Data"
                ])
                
                bulletHeader("Usage Data")
                
                Text("Usage Data is collected automatically when using the Service.")
                    .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))
                    .font(FontHandler.setDubaiFont(weight: .regular))
            }
            
            // Additional sections
            sectionHeader("Contact Us")
            Text("If you have any questions about this Privacy Policy, You can contact us:")
                .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))
                .font(FontHandler.setDubaiFont(weight: .regular))
            bulletList([
                "By email: nomtetes.onetrue@icloud.com",
                "By phone number: 05392469551"
            ])
        }
    }
    
    // Terms of Usage Content
    private var termsOfUsageContent: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Last updated: February 27, 2025")
                .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))
                .font(FontHandler.setDubaiFont(weight: .regular))
            
            Text("Please read these terms of usage carefully before using the AISalah application.")
                .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))
                .font(FontHandler.setDubaiFont(weight: .regular))
            
            sectionHeader("Agreement to Terms")
            
            Text("By accessing or using our application, you agree to be bound by these Terms. If you disagree with any part of the terms, you may not access the application.")
                .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))
                .font(FontHandler.setDubaiFont(weight: .regular))
            
            sectionHeader("Intellectual Property")
            
            Text("The Service and its original content, features, and functionality are and will remain the exclusive property of AISalah and its licensors. The Service is protected by copyright, trademark, and other laws.")
                .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))
                .font(FontHandler.setDubaiFont(weight: .regular))
            
            sectionHeader("User Responsibilities")
            
            Text("As a user of the application, you are responsible for:")
                .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))
                .font(FontHandler.setDubaiFont(weight: .regular))
            
            bulletList([
                "Maintaining the confidentiality of your account",
                "Restricting access to your device",
                "Assuming responsibility for all activities that occur under your account",
                "Notifying us immediately upon unauthorized use of your account"
            ])
            
            // Additional sections as needed
        }
    }
    
    // Helper Views
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .foregroundColor(ColorHandler.getColor(salah, for: .gold))
            .font(FontHandler.setDubaiFont(weight: .bold, size: .l))
            .padding(.top, 10)
    }
    
    private func subSectionHeader(_ title: String) -> some View {
        Text(title)
            .foregroundColor(ColorHandler.getColor(salah, for: .light))
            .font(FontHandler.setDubaiFont(weight: .bold, size: .m))
    }
    
    private func bulletHeader(_ title: String) -> some View {
        Text(title)
            .foregroundColor(ColorHandler.getColor(salah, for: .light))
            .padding(.top, 5)
    }
    
    private func bulletPoint(_ title: String, _ description: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .top) {
                Text("•")
                    .foregroundColor(ColorHandler.getColor(salah, for: .gold))
                Text(title)
                    .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))
                    .font(FontHandler.setDubaiFont(weight: .bold))
            }
            Text(description)
                .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))
                .font(FontHandler.setDubaiFont(weight: .medium))
        }
    }
    
    private func bulletList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top) {
                    Text("•")
                        .foregroundColor(ColorHandler.getColor(salah, for: .gold))
                    Text(item)
                        .foregroundColor(ColorHandler.getColor(salah, for: .oneTrue))

                }
            }
        }
        .padding(.leading, 10)
    }
}
