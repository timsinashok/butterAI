//
//  SlideFromLeadingEdge.swift
//  ButterAI
//
//  Created by NYUAD on 01/02/2025.
//

import SwiftUI

struct SlideFromLeadingEdge: ViewModifier {
    let isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(x: isPresented ? 0 : -UIScreen.main.bounds.width)
            .animation(.spring(response: 0.3), value: isPresented)
    }
}
