//
//  CustomRectangleShape.swift
//  Aiachy
//
//  Created by Mert Türedü on 6.06.2024.
//

import SwiftUI

struct CustomRectangleShape: Shape {
    
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))

        return Path(path.cgPath)
    }
}
