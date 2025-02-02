//
//  LoadingIndicator.swift
//  ButterAI
//
//  Created by NYUAD on 01/02/2025.
//

import SwiftUI

struct LoadingIndicator: View {
    private let duration: Double = 1.0
    @State private var isRotating = false
    
    var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(Color(red: 0.95, green: 0.6, blue: 0.2), style: StrokeStyle(lineWidth: 3, lineCap: .round))
            .frame(width: 30, height: 30)
            .rotationEffect(Angle(degrees: isRotating ? 360 : 0))
            .onAppear {
                withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false)) {
                    isRotating = true
                }
            }
    }
}

#Preview {
    LoadingIndicator()
}
