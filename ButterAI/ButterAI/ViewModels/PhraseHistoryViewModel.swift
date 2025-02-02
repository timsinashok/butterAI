//
//  PhraseHistoryViewModel.swift
//  ButterAI
//
//  Created by NYUAD on 01/02/2025.
//

import Foundation

class PhraseHistoryViewModel: ObservableObject {
    @Published var phraseAttempts: [PhraseAttempt] = []
    
    func addPhraseAttempt(phrase: String, score: Int) {
        let newAttempt = PhraseAttempt(phrase: phrase, score: score, timestamp: Date())
        phraseAttempts.insert(newAttempt, at: 0)
    }
}
