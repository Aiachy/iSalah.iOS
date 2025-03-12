//
//  CircleButtonModel.swift
//  iSalah
//
//  Created by Mert Türedü on 12.03.2025.
//

import Foundation

struct CircleButtonModel {
    
    var size: CGFloat
    var image: ImageHelper.icon
    let action: () -> Void
    
    init(size: CGFloat = 0.1,
         _ image: ImageHelper.icon,
         action: @escaping () -> Void) {
        self.size = size
        self.image = image
        self.action = action
    }
}
