//
//  ProgressView.swift
//  ButterAI
//
//  Created by NYUAD on 01/02/2025.
//

import SwiftUI

struct ProgressView: View {
    @Binding var isPresented: Bool
    @StateObject private var audioManager: AudioRecorderUploader
    @State private var currentScore: Double = 0
    @State private var highestScore: Double = 0
    @State private var progressValue: Double = 0
    @State private var serverResponses: [String] = []
    
    // Predefined array of items to add
    let predefinedItems = ["Monday", "Morning", "Movie"]
    
    init(isPresented: Binding<Bool>, audioManager: AudioRecorderUploader) {
        self._isPresented = isPresented
        self._audioManager = StateObject(wrappedValue: audioManager)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                VStack(spacing: 0) {
                    // Circular Progress View
                    ZStack {
                        // Background Circle
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                            .frame(width: 200, height: 200)
                        
                        // Progress Circle
                        Circle()
                            .trim(from: 0, to: progressValue)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 15, lineCap: .round)
                            )
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 1.0), value: progressValue)
                        
                        // Center Score Display
                        VStack(spacing: 4) {
                            Text("\(Int(highestScore))")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Text("Highest Score")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if currentScore < highestScore {
                                Text("Current: \(Int(currentScore))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.top, 4)
                            }
                        }
                    }
                    .padding(.vertical, 40)
                    
                    // Score Description
                    VStack(spacing: 8) {
                        Text("Practice Progress")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Keep practicing to improve your score!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.vertical)
                    
                    Divider()
                    
                    // New section for server responses
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Mastered phrases:")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(serverResponses.indices, id: \.self) { index in
                                    HStack {
                                        Text("\(index + 1).")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Text(serverResponses[index])
                                            .font(.body)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            // Add play action here
                                            print("Play item: \(serverResponses[index])")
                                        }) {
                                            Image(systemName: "play.circle.fill")
                                                .foregroundColor(.blue)
                                                .imageScale(.large)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .transition(.opacity)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                    
                    Divider()
                }
                .padding(.top, 60)
            }
            
            // Header with Back Button
            VStack {
                ZStack {
                    HStack {
                        Button {
                            withAnimation(.spring()) {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.blue)
                                .padding(8)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .padding(.leading, 16)
                        
                        Spacer()
                    }
                    
                    Text("Progress")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 8)
                
                Spacer()
            }
        }
        .withCommonBackground()
        .onReceive(audioManager.$serverResponse) { response in
            if let newResponse = response, !newResponse.isEmpty {
                withAnimation {
                    // Check if there are still items in predefinedItems
                    if serverResponses.count < predefinedItems.count {
                        let itemToAdd = predefinedItems[serverResponses.count]
                        serverResponses.append(itemToAdd)
                    }
                }
            }
        }
        .onReceive(audioManager.$progressScore) { progress in
            
            withAnimation {
                if let progress = progress {
                    print("DEBUG: Updating Progress - Current: \(progress), Highest: \(highestScore)")
                    
                    currentScore = progress
                    // Reset highest score to 0 if it crosses 100
                   if highestScore >= 100 {
                       highestScore = 0
                   }
                    // Update highest score only if current score is higher
                    if progress > highestScore {
                        highestScore = progress
                    }
                    // Update progress value for the circular animation (0 to 1)
                    progressValue = progress / 100
                    
                    print("DEBUG: After Update - Current: \(currentScore), Highest: \(highestScore), Progress Value: \(progressValue)")
                }
            }
        }
    }
}

#Preview {
    let previewAudioManager = AudioRecorderUploader()
    return ProgressView(isPresented: .constant(true),
                       audioManager: previewAudioManager)
}
