//
//  CustomToggleModel.swift
//  iSalah
//
//  Created by Mert Türedü on 27.02.2025.
//

import Foundation

struct CustomToggleModel {
    
    let onColor: ColorHelper.original
    let offColor: ColorHelper.original
    
    let onThumbColor: ColorHelper.original
    let offThumbColor: ColorHelper.original
    
    let onStrokeColor: ColorHelper.original
    let offStrokeColor: ColorHelper.original
    
    let size: CGSize
    var thumbSize: CGFloat? = nil
    var cornerRadius: CGFloat? = nil
    let animationDuration: Double
    
    init(
        onColor: ColorHelper.original = .islamic,
        offColor: ColorHelper.original = .light,
        
        onThumbColor: ColorHelper.original = .light,
        offThumbColor: ColorHelper.original = .islamic,
        
        onStrokeColor: ColorHelper.original = .light,
        offStrokeColor: ColorHelper.original = .horizon,
    
        size: CGSize = .init(width: 50, height: 25),
        
        thumbSize: CGFloat? = nil,
        cornerRadius: CGFloat? = nil,
        animationDuration: Double = 0.2
    ) {
        /// Background
        self.onColor = onColor
        self.offColor = offColor
        /// Thumb
        self.onThumbColor = onThumbColor
        self.offThumbColor = offThumbColor
        /// Stroke
        self.onStrokeColor = onStrokeColor
        self.offStrokeColor = offStrokeColor
        
        self.size = size
        
        self.thumbSize = thumbSize
        self.cornerRadius = cornerRadius
        self.animationDuration = animationDuration
    }
    
}
