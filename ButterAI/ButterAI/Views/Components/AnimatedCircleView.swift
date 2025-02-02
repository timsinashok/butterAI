//
//  AnimatedCircleView.swift
//  ButterAI
//
//  Created by NYUAD on 01/02/2025.
//

import SwiftUI

struct FloatingParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat
    var speed: Double
    var opacity: Double
}

struct AnimatedCircleView: View {
    let isActive: Bool
    let size: CGFloat
    
    @State private var particles: [FloatingParticle] = []
    @State private var phase: CGFloat = 0
    @State private var innerRotation: Double = 0
    @State private var outerRotation: Double = 0
    
    private let gradient = LinearGradient(
        colors: [
            Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.8),
            Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.4)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    init(isActive: Bool, size: CGFloat) {
        self.isActive = isActive
        self.size = size
        
        // Initialize particles
        _particles = State(initialValue: (0..<15).map { _ in
            FloatingParticle(
                position: CGPoint(
                    x: CGFloat.random(in: -size/2...size/2),
                    y: CGFloat.random(in: -size/2...size/2)
                ),
                scale: CGFloat.random(in: 4...8),
                speed: Double.random(in: 0.5...2),
                opacity: Double.random(in: 0.3...0.7)
            )
        })
    }
    
    var body: some View {
        ZStack {
            // Base circle with gradient
            Circle()
                .fill(gradient)
                .frame(width: size, height: size)
                .blur(radius: 10)
            
            // Outer glow
            Circle()
                .stroke(Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.3), lineWidth: 8)
                .frame(width: size + 10, height: size + 10)
                .blur(radius: 8)
                .rotationEffect(.degrees(outerRotation))
            
            // Inner rotating gradient
            Circle()
                .fill(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.6),
                            Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.3),
                            Color(red: 0.3, green: 0.8, blue: 0.5).opacity(0.6)
                        ]),
                        center: .center
                    )
                )
                .frame(width: size - 20, height: size - 20)
                .rotationEffect(.degrees(innerRotation))
            
            // Floating particles
            ForEach(particles) { particle in
                Circle()
                    .fill(Color.white.opacity(particle.opacity))
                    .frame(width: particle.scale, height: particle.scale)
                    .blur(radius: 2)
                    .position(
                        x: size/2 + particle.position.x,
                        y: size/2 + particle.position.y
                    )
            }
        }
        .clipShape(Circle())
        .onReceive(timer) { _ in
            guard isActive else { return }
            
            // Update rotations
            withAnimation(.linear(duration: 0.016)) {
                innerRotation += 0.2
                outerRotation -= 0.1
                phase += 0.02
            }
            
            // Update particles
            for i in particles.indices {
                var particle = particles[i]
                
                // Create circular motion
                let radius = sqrt(
                    pow(particle.position.x, 2) +
                    pow(particle.position.y, 2)
                )
                let angle = atan2(
                    particle.position.y,
                    particle.position.x
                ) + 0.01 * particle.speed
                
                particle.position = CGPoint(
                    x: radius * cos(angle),
                    y: radius * sin(angle)
                )
                
                // Update opacity for twinkling effect
                particle.opacity = 0.3 + (sin(phase * particle.speed) + 1) * 0.2
                
                particles[i] = particle
            }
        }
    }
}

#Preview {
    AnimatedCircleView(isActive: true, size: 84)
        .frame(width: 100, height: 100)
        .background(Color(red: 0.95, green: 0.95, blue: 0.96))
}
