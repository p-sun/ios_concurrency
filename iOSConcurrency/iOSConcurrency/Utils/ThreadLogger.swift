//
//  ThreadLogger.swift
//  iOSConcurrency
//
//  Created by Paige Sun on 2023-09-05.
//

import Foundation

struct ThreadLogger {
    private static let threadIcons = [
        "⬜️", "🟥", "🟨", "🟩", "🟦", "🟪", "🟧", "🟫",
        "⬜️⬜️","⬜️🟥", "⬜️🟨", "⬜️🟩", "⬜️🟦", "⬜️🟪", "⬜️🟧", "⬜️🟫",
        "🟨⬜️","🟨🟥", "🟨🟨", "🟨🟩", "🟨🟦", "🟨🟪", "🟨🟧", "🟨🟫",
        "🟩⬜️","🟩🟥", "🟩🟨", "🟩🟩", "🟩🟦", "🟩🟪", "🟩🟧", "🟩🟫",
        "🟦⬜️","🟦🟥", "🟦🟨", "🟦🟩", "🟦🟦", "🟦🟪", "🟦🟧", "🟦🟫",
        "🟪⬜️","🟪🟥", "🟪🟨", "🟪🟩", "🟪🟦", "🟪🟪", "🟪🟧", "🟪🟫",
        "🟧⬜️","🟧🟥", "🟧🟨", "🟧🟩", "🟧🟦", "🟧🟪", "🟧🟧", "🟧🟫",
        "🟫⬜️","🟫🟥", "🟫🟨", "🟫🟩", "🟫🟦", "🟫🟪", "🟫🟧", "🟫🟫",
    ]
    
    private static var threadToIcon = [String: String]()
    private static let queue = DispatchQueue(label: "paige.ThreadLogger.queue")
    
    static func log(_ prefix: String) {
        let threadStr = Thread.current.description
        
        let regex = /(<.*Thread:.*>){number = (\d+).*}/
        if let match = threadStr.firstMatch(of: regex) {
            let icon = threadIcons[Int(match.2)! % threadIcons.count]
            print(prefix, "| \(icon) Thread \(match.2)")
        } else {
            print(prefix, "| Thread:", threadStr)
        }
    }
}
