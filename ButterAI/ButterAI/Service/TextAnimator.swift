//
//  TextAnimator.swift
//  ButterAI
//
//  Created by NYUAD on 01/02/2025.
//

import Foundation

class TextAnimator: ObservableObject {
    @Published var displayedText: String = ""
    private var fullText: String = ""
    private var chunks: [String] = []
    private var currentChunkIndex: Int = 0
    
    func setText(_ text: String) {
        self.fullText = text
        self.displayedText = ""
        self.currentChunkIndex = 0
        // Split text into chunks (by sentences or custom delimiter)
        self.chunks = text.components(separatedBy: ". ")
            .map { $0.trimmingCharacters(in: .whitespaces) + ". " }
        animateNextChunk()
    }
    
    private func animateNextChunk() {
        guard currentChunkIndex < chunks.count else { return }
        
        let chunk = chunks[currentChunkIndex]
        displayedText += chunk
        
        currentChunkIndex += 1
        
        if currentChunkIndex < chunks.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.animateNextChunk()
            }
        }
    }
    
    func reset() {
        displayedText = ""
        currentChunkIndex = 0
        chunks = []
    }
}
