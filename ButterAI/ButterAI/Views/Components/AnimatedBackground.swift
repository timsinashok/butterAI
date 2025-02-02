//
//  AnimatedBackground.swift
//  ButterAI
//
//  Created by NYUAD on 31/01/2025.
//

import SwiftUI

struct GlitterParticle: Identifiable {
    let id = UUID()
    var position: CGPoint
    var scale: CGFloat
    var opacity: Double
    var speed: Double
    var phase: Double
    var colorIndex: Int  // Added to support multiple colors
}

struct AnimatedBackground: View {
    // Customizable properties
    let particleCount = 150  // Increased particle count
    let waveFrequency = 5.0  // Higher values = more frequent waves
    let waveAmplitude = 30.0  // Higher values = wider waves
    
    // Color options
    let particleColors: [[Color]] = [
        [Color(red: 1.0, green: 0.8, blue: 0.8), Color(red: 1.0, green: 0.9, blue: 0.9)],  // Pink
        [Color(red: 0.8, green: 0.9, blue: 1.0), Color(red: 0.9, green: 0.95, blue: 1.0)], // Light Blue
        [Color(red: 0.8, green: 1.0, blue: 0.8), Color(red: 0.9, green: 1.0, blue: 0.9)],  // Light Green
        [Color(red: 1.0, green: 0.8, blue: 1.0), Color(red: 1.0, green: 0.9, blue: 1.0)],  // Purple
        [Color(red: 1.0, green: 1.0, blue: 0.8), Color(red: 1.0, green: 1.0, blue: 0.9)]   // Gold
    ]
    
    @State private var particles: [GlitterParticle] = []
    @State private var time: Double = 0
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    init() {
        // Initialize particles
        _particles = State(initialValue: (0..<150).map { _ in
            GlitterParticle(
                position: CGPoint(
                    x: CGFloat.random(in: -20...420),
                    y: CGFloat.random(in: -20...920)
                ),
                scale: CGFloat.random(in: 2...8),  // Slightly larger particles
                opacity: Double.random(in: 0.5...0.7),
                speed: Double.random(in: 0.5...2.5),  // Increased speed variation
                phase: Double.random(in: 0...2 * .pi),
                colorIndex: Int.random(in: 0..<5)  // Random color selection
            )
        })
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.96) // Subtle cool gray
                    .ignoresSafeArea()
                
                ForEach(particles) { particle in
                    Circle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: particleColors[particle.colorIndex]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: particle.scale, height: particle.scale)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onReceive(timer) { _ in
                updateParticles(in: geometry.size)
            }
        }
    }
    
    private func updateParticles(in size: CGSize) {
        time += 0.016
        
        for i in particles.indices {
            var particle = particles[i]
            
            // Create more dynamic wave-like movement
            let primaryWave = sin(time * waveFrequency * particle.speed + particle.phase) * waveAmplitude
            let secondaryWave = cos(time * waveFrequency * 0.5 * particle.speed + particle.phase) * (waveAmplitude * 0.5)
            let combinedWave = primaryWave + secondaryWave
            
            // Move particles upward with complex wave pattern
            particle.position.y -= 0.7 * particle.speed  // Faster upward movement
            particle.position.x += combinedWave * 0.02
            
            // Reset particles that move off screen
            if particle.position.y < -20 {
                particle.position.y = size.height + 20
                particle.position.x = CGFloat.random(in: -20...size.width+20)
                particle.opacity = Double.random(in: 0.5...0.7)
                particle.speed = Double.random(in: 0.5...2.5)
                particle.phase = Double.random(in: 0...2 * .pi)
                particle.colorIndex = Int.random(in: 0..<5)  // New random color when recycling
            }
            
            // Enhanced twinkling effect
            let fastTwinkle = sin(time * 5 + particle.phase) * 0.25  // Reduced variation to keep higher minimum
            let slowTwinkle = sin(time * 2.5 + particle.phase) * 0.15  // Reduced variation to keep higher minimum
            let combinedTwinkle = (fastTwinkle + slowTwinkle + 0.8)  // Increased base value to 0.8
            particle.opacity = max(0.5, min(1.0, combinedTwinkle))
            
            particles[i] = particle
        }
    }
}


#Preview {
    AnimatedBackground()
}
