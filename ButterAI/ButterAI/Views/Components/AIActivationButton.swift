//
//  AIActivationButton.swift
//  ButterAI
//
//  Created by NYUAD on 31/01/2025.
//

import SwiftUI


struct AIActivationButton: View {
    @State private var isActive = false
    @State private var isLocked = false
    @State private var circlePosition: CGFloat = 0
    @State private var isDragging = false
    @GestureState private var isDetectingLongPress = false
    let audioManager: AudioRecorderUploader
    
    var onActivate: () -> Void
    var onDeactivate: () -> Void
    var onLock: () -> Void
    var onUnlock: () -> Void
    
    private let buttonSize: CGFloat = 74
    private let lockTargetSize: CGFloat = 50
    private let lockThreshold: CGFloat = 160
    
    private var lockIconOpacity: Double {
        if isLocked { return 1.0 }
        let progress = circlePosition / lockThreshold
        return progress < 0.5 ? 0 : Double(progress * 2 - 1)
    }
    
    private var isNearLock: Bool {
        circlePosition > lockThreshold * 0.9
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack {
                Spacer()
                
                ZStack {
                    // Lock target
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: lockTargetSize, height: lockTargetSize)
                        
                        Image(systemName: "lock.fill")
                            .font(.system(size: 20))
                            .foregroundColor(isNearLock ? .blue : .gray)
                    }
                    .opacity(lockIconOpacity)
                    .offset(x: lockThreshold)
                    
                    // Main button
                    ZStack {
                        // Stationary outer circle
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: buttonSize, height: buttonSize)
                        
                        if audioManager.isUploading {
                            // Custom loading indicator
                            LoadingIndicator()
                        } else {
                            // Inner circle
                            Circle()
                                .fill(isActive || isLocked ? Color(red: 0.95, green: 0.6, blue: 0.2) : Color(red: 0.7, green: 0.7, blue: 0.7))
                                .frame(width: isDragging || isLocked ? buttonSize - 30 : buttonSize - 15)
                                .offset(x: circlePosition)
                                .scaleEffect(isDetectingLongPress || isDragging ? 0.8 : 1.0)
                                .animation(.spring(response: 0.3), value: isDragging)
                                .animation(.spring(response: 0.3), value: isLocked)
                                .animation(.spring(response: 0.3), value: isActive)
                        }
                    }
                }
                .frame(width: buttonSize + lockThreshold)
                
                Spacer()
            }
            .onTapGesture {
                guard !audioManager.isUploading && !isLocked && !isDragging else { return }
                withAnimation(.spring()) {
                    isActive.toggle()
                    if isActive {
                        onActivate()
                    } else {
                        onDeactivate()
                    }
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard !audioManager.isUploading else { return }
                        isDragging = true
                        let dragAmount = value.translation.width
                        
                        if isLocked {
                            // When locked, allow dragging back to center
                            let newPosition = lockThreshold + dragAmount
                            circlePosition = max(0, min(lockThreshold, newPosition))
                            
                            // Unlock if dragged back to center
                            if circlePosition < lockThreshold * 0.1 {
                                withAnimation(.spring()) {
                                    isLocked = false
                                    isActive = false
                                    circlePosition = 0
                                    onDeactivate()
                                    onUnlock()
                                }
                            }
                        } else {
                            // Regular dragging
                            if !isActive {
                                isActive = true
                                onActivate()
                            }
                            
                            let newPosition = dragAmount
                            circlePosition = max(0, min(lockThreshold, newPosition))
                            
                            // Lock if dragged to threshold
                            if circlePosition > lockThreshold * 0.9 && !isLocked {
                                withAnimation(.spring()) {
                                    isLocked = true
                                    circlePosition = lockThreshold
                                    onLock()
                                }
                            }
                        }
                    }
                    .onEnded { _ in
                        guard !audioManager.isUploading else { return }
                        isDragging = false
                        if !isLocked {
                            withAnimation(.spring()) {
                                circlePosition = 0
                                isActive = false
                                onDeactivate()
                            }
                        } else {
                            withAnimation(.spring()) {
                                circlePosition = lockThreshold
                            }
                        }
                    }
            )
            .simultaneousGesture(
                LongPressGesture(minimumDuration: 0.1)
                    .updating($isDetectingLongPress) { currentState, gestureState, _ in
                        gestureState = currentState
                    }
                    .onEnded { _ in
                        guard !audioManager.isUploading else { return }
                        if !isLocked && !isDragging {
                            isActive = true
                            onActivate()
                        }
                    }
            )
        }
        .frame(height: 100)
        .padding(.bottom, 30)
        .allowsHitTesting(!audioManager.isUploading)
    }
}

#Preview {
    let previewAudioManager = AudioRecorderUploader()
    
    return AIActivationButton(
        audioManager: previewAudioManager,
        onActivate: { print("Activated") },
        onDeactivate: { print("Deactivated") },
        onLock: { print("Locked") },
        onUnlock: { print("Unlocked") }
    )
    .background(Color(red: 0.95, green: 0.95, blue: 0.96))
}
