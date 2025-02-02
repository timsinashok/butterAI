//
//  MainView.swift
//  ButterAI
//
//  Created by NYUAD on 31/01/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct MainView: View {
    @State private var isAIActive = false
    @State private var showingProfile = false
    @State private var showingProgress = false
    @State private var currentPhrase = "Please repeat after me: Hello, how are you today?"
    @StateObject private var phraseHistory = PhraseHistoryViewModel()
    @StateObject private var audioManager = AudioRecorderUploader()

    
    var body: some View {
        ZStack {
            // Main Content
            ZStack {
                // Background
                AnimatedBackground()
                
                // Content
                VStack(spacing: 0) {
                    // Top Navigation Buttons
                    HStack {
                        CircularNavButton(
                            icon: "person.circle",
                            action: { withAnimation(.spring()) { showingProfile.toggle() } }
                        )
                        
                        Spacer()
                        
                        CircularNavButton(
                            icon: "chart.bar.fill",
                            action: { withAnimation(.spring()) { showingProgress.toggle() } }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    // 3D Model Area
                    VStack(spacing: 16) {
                        ZStack {
                            Image("static_therapist")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                                .opacity(audioManager.isPlaying ? 0 : 1)
                            
                            AnimatedImage(name: "talking_therapist.gif")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                                .opacity(audioManager.isPlaying ? 1 : 0)
                        }
                        .animation(.easeInOut(duration: 0.3), value: audioManager.isPlaying)
                        
                        Text(audioManager.serverResponse ?? "Hey! how's the weather today?")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: 300)
                            .padding(.horizontal)
                            .padding(.top, 40)
                    }
                    
                    Spacer()
                    
                    if isAIActive {
                        Text("AI Active - Listening...")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.95, green: 0.6, blue: 0.2))
                            .padding(.bottom, 20)
                    }
                    
                    AIActivationButton(
                        audioManager: audioManager,
                        onActivate: {
                            isAIActive = true
                            audioManager.toggleRecording()
                        },
                        onDeactivate: {
                            isAIActive = false
                            audioManager.toggleRecording()
                        },
                        onLock: {
                            print("AI locked")
                        },
                        onUnlock: {
                            print("AI unlocked")
                        }
                    )
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            
            // Profile View Sliding from Left
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    ProfileView(isPresented: $showingProfile)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .background(Color(.systemBackground))
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: geometry.size.width)
                }
                .offset(x: showingProfile ? 0 : -geometry.size.width)
            }
            .zIndex(2)
            
            // Progress View Sliding from Right
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: geometry.size.width)
                    
                    ProgressView(isPresented: $showingProgress, audioManager: audioManager)
                        .frame(width: geometry.size.width)
                }
                .offset(x: showingProgress ? -geometry.size.width : 0)
            }
            .zIndex(2)
        }
        .animation(.spring(), value: showingProfile)
        .animation(.spring(), value: showingProgress)
        .onReceive(audioManager.$serverResponse) { newResponse in
            // Optional: Add any additional logic when server response changes
            print("Received server response: \(newResponse ?? "nil")")
        }
    }
}

#Preview {
    MainView()
}
