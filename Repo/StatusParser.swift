//
//  StatusParser.swift
//  RepoStatus
//
//  Created by Beavis, Simon on 4/04/23.
//

import Foundation

struct StatusParser {

    let lines: [String.SubSequence]
    var details = StatusDetails()

    init(_ lines: [String.SubSequence]) {
        self.lines = lines
    }

    mutating func parse() throws -> StatusDetails {
        for line in lines {
            let s = String(line)

            try getCurrentBranch(from: s)
            try getAheadCount(from: s)
            try getBehindCount(from: s)
            try extractStatus(from: s)

            details.isValid = true
        }
        return details
    }

    // MARK: - Regex methods

    /*
     o   ' ' = unmodified
     o   M = modified
     o   A = added
     o   D = deleted
     o   R = renamed
     o   C = copied
     o   U = updated but unmerged

     git stash list
     stash@{0}: WIP on master: e17d064 Case insensitive sorting
     */

    private func match(in string: String, using regex: NSRegularExpression) -> [NSTextCheckingResult] {
        let matches = regex.matches(in: string,
                                    options: [],
                                    range: NSRange(location: 0, length: string.count))
        return matches
    }

    private mutating func extractStatus(from string: String) throws {
        let regex = try NSRegularExpression(pattern: "(.)(.)\\ .+")

        let matches = match(in: string, using: regex)

        for match in matches {
            if match.numberOfRanges >= 3 {
                let firstValue = string.subString(range: match.range(at: 1))
                set(in: &details.indexAttributes, from: firstValue)

                let secondValue = string.subString(range: match.range(at: 2))
                set(in: &details.workingCopyAttributes, from: secondValue)
            }
        }
    }

    private func getIntMatchValue(from string: String, using regexString: String) throws -> Int {
        let regex = try NSRegularExpression(pattern: regexString)
        let matches = match(in: string, using: regex)
        if let match = matches.first {
            if match.numberOfRanges > 1 {
                return Int(string.subString(range: match.range(at: 1))) ?? 0
            }
        }
        return 0
    }

    private func getStringMatch(from string: String, using regexString: String) throws -> String? {
        let regex = try NSRegularExpression(pattern: regexString)
        let matches = match(in: string, using: regex)
        if let match = matches.first {
            if match.numberOfRanges > 1 {
                return string.subString(range: match.range(at: 1))
            }
        }
        return nil
    }

    private mutating func getCurrentBranch(from string: String) throws {
        // ... ## master...origin/master [ahead 1]
        if let branchMatch = try getStringMatch(from: string, using: "##\\ ?([^.\\ \\?\\*\\[]*)") {
            details.branch = branchMatch
        }
    }

    private mutating func getAheadCount(from string: String) throws {
        // ... ##\ (.*)\\.\\.\\..+\\[ahead.+([0-9]+)\\]
        let count = try getIntMatchValue(from: string, using: ".+\\[ahead\\s+([0-9]+)\\]")
        if count > 0 {
            details.aheadCount = count
            // workingCopyAttributes.insert(.ahead)
        }
    }

    private mutating func getBehindCount(from string: String) throws {
        let count = try getIntMatchValue(from: string, using: ".+\\[behind\\s+([0-9]+)\\]")
        if count > 0 {
            details.behindCount = count
            // workingCopyAttributes.insert(.behind)
        }
    }

    private func set(in attributeSet: inout AttributeSet, from string: String) {
        switch string.uppercased() {
            case "?":
                attributeSet.insert(.newUntrackedFiles)
            case "M":
                attributeSet.insert(.modifiedFiles)
            case "A":
                attributeSet.insert(.addedFiles)
            case "R":
                attributeSet.insert(.renamedFiles)
            case "C":
                attributeSet.insert(.copiedFiles)
            case "D":
                attributeSet.insert(.deletedFiles)
            default:
                break
        }
    }


}
