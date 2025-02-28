//
//  ScrollViewWithOffset.swift
//  iSalah
//
//  Created by Mert Türedü on 28.02.2025.
//

import SwiftUI

// UIKit tabanlı scroll view takibi yapan wrapper
struct ScrollViewWithOffset<Content: View>: UIViewRepresentable {
    let onScroll: (CGFloat) -> Void
    let content: Content
    
    init(onScroll: @escaping (CGFloat) -> Void, @ViewBuilder content: () -> Content) {
        self.onScroll = onScroll
        self.content = content()
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.delegate = context.coordinator
        
        // Arka planı şeffaf yap
        scrollView.backgroundColor = .clear
        
        // SwiftUI içeriğini UIKit ScrollView'e ekle
        let hostingController = UIHostingController(rootView: content)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Hosting controller'ın arka planını da şeffaf yap
        hostingController.view.backgroundColor = .clear
        
        scrollView.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: scrollView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            hostingController.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // İçerik güncellendiğinde ScrollView'i güncelle
        if let hostView = uiView.subviews.first {
            // Arka planın şeffaf kalmasını sağla
            uiView.backgroundColor = .clear
            hostView.backgroundColor = .clear
            
            hostView.frame.size.height = hostView.systemLayoutSizeFitting(
                CGSize(width: uiView.frame.width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ).height
            uiView.contentSize = hostView.frame.size
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onScroll: onScroll)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        let onScroll: (CGFloat) -> Void
        
        init(onScroll: @escaping (CGFloat) -> Void) {
            self.onScroll = onScroll
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            onScroll(scrollView.contentOffset.y)
        }
    }
}
