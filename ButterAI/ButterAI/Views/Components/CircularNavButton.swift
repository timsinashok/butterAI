//
//  CircularNavButton.swift
//  ButterAI
//
//  Created by NYUAD on 01/02/2025.
//

import SwiftUI

struct CircularNavButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
            }
        }
    }
}


#Preview {
    CircularNavButton(
        icon: "person.circle",
        action: { print("Button tapped") }
    )
    .padding()
    .background(Color(red: 0.95, green: 0.95, blue: 0.96))
}
