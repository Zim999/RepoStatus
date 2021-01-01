//
//  String+Extension.swift
//  GitMonitor
//
//  Created by Simon Beavis on 10/18/20.
//

import Foundation

extension String {
    /// Return a substring of a string, as a string
    /// - Parameter range: Range of the substring
    /// - Returns: The substring
    func subString(range: NSRange) -> String {
        let startIdx = index(startIndex, offsetBy: range.lowerBound)
        let endIdx = index(startIndex, offsetBy: range.upperBound)
        
        let substring = self[startIdx..<endIdx]
        return String(substring)
    }
    
    /// Trims leading and trailing whitespace and newlines from the string
    mutating func trim() {
        self = trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
