//
//  DateFormatter.swift
//  ButterAI
//
//  Created by NYUAD on 01/02/2025.
//

import Foundation

extension Date {
    
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
