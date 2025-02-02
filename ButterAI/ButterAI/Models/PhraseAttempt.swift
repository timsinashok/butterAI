//
//  PhraseAttempts.swift
//  ButterAI
//
//  Created by NYUAD on 01/02/2025.
//

import Foundation

struct PhraseAttempt: Identifiable {
    let id = UUID()
    let phrase: String
    let score: Int
    let timestamp: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}
