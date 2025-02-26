//
//  ImageHandler.swift
//  iSalah
//
//  Created by Mert Türedü on 20.02.2025.
//

import SwiftUI

struct ImageHandler {
    
    static func getIcon(_ state: iSalahState, image: ImageHelper.icon, render: Image.TemplateRenderingMode = .template) -> Image {
        
        return Image(image.rawValue)
            .resizable()
            .renderingMode(render)
    }
    
    static func getMassive(_ state: iSalahState, image: ImageHelper.massive, render: Image.TemplateRenderingMode = .original) -> Image {
        
        return Image(image.rawValue)
            .resizable()
            .renderingMode(render)
    }
    
}
