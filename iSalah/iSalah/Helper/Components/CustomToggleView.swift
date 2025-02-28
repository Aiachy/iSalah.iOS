//
//  CustomToggleView.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import SwiftUI

struct CustomToggleView: View {
    @EnvironmentObject var salah: iSalahState

    @Binding var isOn: Bool
    let model: CustomToggleModel
    
    init(
        _ isOn: Binding<Bool>,
        model: CustomToggleModel = .init()
    ) {
        _isOn = isOn
    
        self.model = model
    }
    
    // Hesaplanmış değerler
    private var thumbDiameter: CGFloat {
        return model.thumbSize ?? model.size.height - 4
    }
    
    private var toggleRadius: CGFloat {
        return model.cornerRadius ?? model.size.height / 2
    }
    
    // Thumb (top) pozisyonu
    private var thumbPosition: CGFloat {
        return isOn ? model.size.width - thumbDiameter - 3 : 3
    }
    
    var body: some View {
        ZStack {
            /// Background
            backgroundView
            
            thumbView
        }
        .frame(width: model.size.width, height: model.size.height)
        .onTapGesture {
            isOn.toggle()
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        CustomToggleView(.constant(false))
    }
    .environmentObject(mockSalah)
}

extension CustomToggleView {
    
    var backgroundView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: toggleRadius)
                .fill(ColorHandler.getColor(salah, for: isOn ? model.onColor : model.offColor))
            RoundedRectangle(cornerRadius: toggleRadius)
                .stroke(ColorHandler.getColor(salah, for: isOn ? model.onStrokeColor : model.offStrokeColor))
        }
        .frame(width: model.size.width, height: model.size.height)

    }
    
    var thumbView: some View {
        Circle()
            .fill(ColorHandler.getColor(salah, for: isOn ? model.onThumbColor : model.offThumbColor))
            .frame(width: thumbDiameter, height: thumbDiameter)
            .shadow(radius: 1)
            .offset(x: thumbPosition - model.size.width / 2 + thumbDiameter / 2, y: 0)
            .animation(.spring(response: model.animationDuration), value: isOn)
    }
}
