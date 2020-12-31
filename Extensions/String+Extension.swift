//
//  String+Extension.swift
//  GitMonitor
//
//  Created by Simon Beavis on 10/18/20.
//

import Foundation

extension String {
    func subString(range: NSRange) -> String {
        let startIdx = index(startIndex, offsetBy: range.lowerBound)
        let endIdx = index(startIndex, offsetBy: range.upperBound)
        
        let substring = self[startIdx..<endIdx]
        return String(substring)
    }

    mutating func trim() {
        self = trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
