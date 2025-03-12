//
//  FontHandler.swift
//  iSalah
//
//  Created by Mert Türedü on 26.02.2025.
//
import SwiftUI

struct FontHandler {
    
    static func setDubaiFont(weight: FontHelper.Dubai? = nil, size: FontHelper.Size? = nil) -> Font {
        let fontName = weight?.rawValue ?? FontHelper.Dubai.regular.rawValue
        let fontSize = size?.rawValue ?? FontHelper.Size.m.rawValue
        
//        print("Dubai font active: \(fontName) with size: \(fontSize)")
        
        if let _ = UIFont(name: fontName, size: fontSize) {
            return Font.custom(fontName, size: fontSize)
        } else {
//            print("⚠️ WARNING: Font \(fontName) not found, falling back to system font")
            return Font.system(size: fontSize)
        }
    }
    
    static func setNewYorkFont(weight: FontHelper.NewYork? = nil, size: FontHelper.Size? = nil) -> Font {
        let fontSize = size?.rawValue ?? FontHelper.Size.m.rawValue
        
        var fontWeight: Font.Weight = .medium
        var isItalic = false
        
        if let weight = weight {
            switch weight {
            case .black, .blackItalic:
                fontWeight = .black
                isItalic = weight == .blackItalic
            case .bold, .boldItalic:
                fontWeight = .bold
                isItalic = weight == .boldItalic
            case .heavy, .heavyItalic:
                fontWeight = .heavy
                isItalic = weight == .heavyItalic
            case .medium, .mediumItalic:
                fontWeight = .medium
                isItalic = weight == .mediumItalic
            case .regular, .regularItalic:
                fontWeight = .regular
                isItalic = weight == .regularItalic
            case .semibold, .semiboldItalic:
                fontWeight = .semibold
                isItalic = weight == .semiboldItalic
            }
        }
        
        var font = Font.system(size: fontSize, weight: fontWeight, design: .serif)
        
        if isItalic {
            font = font.italic()
        }
        
//        print("Using system New York font: weight=\(fontWeight), size=\(fontSize), italic=\(isItalic)")
        return font
    }
    
    static func printAvailableFonts() {
        print("📋 PRINTING ALL AVAILABLE FONT FAMILIES AND FONTS:")
        for family in UIFont.familyNames.sorted() {
            print("Font family: \(family)")
            for font in UIFont.fontNames(forFamilyName: family).sorted() {
                print("- \(font)")
            }
        }
        
        // Specifically check for Dubai fonts
        print("\n🔍 CHECKING FOR DUBAI FONTS:")
        for weight in FontHelper.Dubai.allCases {
            let fontName = weight.rawValue
            if UIFont(name: fontName, size: 16) != nil {
                print("✅ \(fontName) is available")
            } else {
                print("❌ \(fontName) is NOT available")
            }
        }
        
        // Check for system serif fonts
        print("\n🔍 USING SYSTEM SERIF FONTS INSTEAD OF CUSTOM NEWYORK FONTS")
        print("System serif fonts are always available with all weights")
    }
}

struct FontTester: View {
    var body: some View {
        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                Text("Dubai Font Tests")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .padding(.top, 20)
//                
//                // Dubai font tests
//                Group {
//                    Text("Dubai Regular")
//                        .font(FontHandler.setDubaiFont(weight: .regular, size: .l))
//                    
//                    Text("Dubai Medium")
//                        .font(FontHandler.setDubaiFont(weight: .medium, size: .l))
//                    
//                    Text("Dubai Light")
//                        .font(FontHandler.setDubaiFont(weight: .light, size: .l))
//                    
//                    Text("Dubai Bold")
//                        .font(FontHandler.setDubaiFont(weight: .bold, size: .l))
//                }
//                
//                Divider()
//                
//                Text("NewYork Font Tests (System Serif)")
//                    .font(.title)
//                    .fontWeight(.bold)
//                    .padding(.top, 10)
//                
//                // NewYork font tests (using system serif)
//                Group {
//                    Text("New York Regular")
//                        .font(FontHandler.setNewYorkFont(weight: .regular, size: .l))
//                    
//                    Text("New York Medium")
//                        .font(FontHandler.setNewYorkFont(weight: .medium, size: .l))
//                    
//                    Text("New York SemiBold")
//                        .font(FontHandler.setNewYorkFont(weight: .semibold, size: .l))
//                    
//                    Text("New York Bold")
//                        .font(FontHandler.setNewYorkFont(weight: .bold, size: .l))
//                    
//                    Text("New York Heavy")
//                        .font(FontHandler.setNewYorkFont(weight: .heavy, size: .l))
//                    
//                    Text("New York Black")
//                        .font(FontHandler.setNewYorkFont(weight: .black, size: .l))
//                    
//                    Text("New York Italic")
//                        .font(FontHandler.setNewYorkFont(weight: .regularItalic, size: .l))
//                }
//                
//                Divider()
//                
//                Button("Print Available Fonts") {
//                    FontHandler.printAvailableFonts()
//                }
//                .padding()
//                .background(Color.blue)
//                .foregroundColor(.white)
//                .cornerRadius(8)
//                .padding(.bottom, 20)
//            }
//            .padding()
        }
    }
}

struct FontTester_Previews: PreviewProvider {
    static var previews: some View {
        FontTester()
    }
}
