//
//  APIError.swift
//  ButterAI
//
//  Created by NYUAD on 01/02/2025.
//

import Foundation

enum APIError: Error {
    case networkError(Error)
    case invalidResponse
    case serverError(Int)
    case encodingError
    case noAudioData
}
