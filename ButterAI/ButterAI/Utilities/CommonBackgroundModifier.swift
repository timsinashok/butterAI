//
//  CommonBackgroundModifier.swift
//  ButterAI
//
//  Created by NYUAD on 01/02/2025.
//

import SwiftUI

struct CommonBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            // Background
            AnimatedBackground()
            
            // Content
            content
        }
    }
}

// Extension to make it easier to apply the background
extension View {
    func withCommonBackground() -> some View {
        self.modifier(CommonBackgroundModifier())
    }
}
