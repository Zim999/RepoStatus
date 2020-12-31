//
//  RepoStatus.swift
//  GitMonitor
//
//  Created by Simon Beavis on 10/18/20.
//

import Foundation

/// Represents status of a Git Rrepo
class RepoStatus {
    
    /// Attributes of the current repo status
    enum Attribute {
        case newUntrackedFiles
        case modifiedFiles
        case addedFiles
        case deletedFiles
        case renamedFiles
        case copiedFiles
        case hasStash
        case ahead
        case behind
    }
    
    /// Current attributes of the repo
    var attributes = Set<Attribute>()
    
    /// Has valid status been retrieved about the repo
    var isValid = false
    
    /// Number of commits ahead working copy is compared to remote
    var aheadCount = 0

    /// Number of commits behind working copy is compared to remote
    var behindCount = 0
    
    /// Current branch
    var branch = "..."

    init() {
        isValid = false
    }
    
    /// Create an instance of RepoStatus, from the output of the git status command
    /// - Parameters:
    ///   - statusLines: Output from th git status command
    ///   - stashList: Output from the git stash lst command
    init(from statusLines: String?, stashList: String?) {
        guard let statusLines = statusLines,
              statusLines != "" else {
            return
        }
        
        let lines = statusLines.split(separator: "\n")
        
        do {
            for line in lines {
                let s = String(line)
                
                try getCurrentBranch(from: s)
                try getAheadCount(from: s)
                try getBehindCount(from: s)
                try extractStatus(from: s)

                if (stashList?.count ?? 0) > 0 {
                    attributes.insert(.hasStash)
                }
                
                isValid = true
            }
        }
        catch {
            print("Exception in RepoStatus init \(error)")
        }
    }
    
    public func contains(_ attribute: Attribute) -> Bool {
        return attributes.contains(attribute)
    }
}

// MARK: - Regex methods

extension RepoStatus {
    
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
    
    private func extractStatus(from string: String) throws {
        let regex = try NSRegularExpression(pattern: "(.)(.)\\ .+")
        
        let matches = match(in: string, using: regex)
        
        for match in matches {
            if match.numberOfRanges >= 3 {
                let firstValue = string.subString(range: match.range(at: 1))
                set(from: firstValue)
                
                let secondValue = string.subString(range: match.range(at: 2))
                set(from: secondValue)
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
    
    private func getCurrentBranch(from string: String) throws {
        // ... ## master...origin/master [ahead 1]
        if let branchMatch = try getStringMatch(from: string, using: "##\\ ?([^.\\ \\?\\*\\[]*)") {
            branch = branchMatch
        }
    }
    
    private func getAheadCount(from string: String) throws {
        // ... ##\ (.*)\\.\\.\\..+\\[ahead.+([0-9]+)\\]
        let count = try getIntMatchValue(from: string, using: ".+\\[ahead.+([0-9]+)\\]")
        if count > 0 {
            aheadCount = count
            attributes.insert(.ahead)
        }
    }
    
    private func getBehindCount(from string: String) throws {
        let count = try getIntMatchValue(from: string, using: ".+\\[behind.+([0-9]+)\\]")
        if count > 0 {
            behindCount = count
            attributes.insert(.behind)
        }
    }

    private func set(from string: String) {
        switch string.uppercased() {
            case "?":
                attributes.insert(.newUntrackedFiles)
            case "M":
                attributes.insert(.modifiedFiles)
            case "A":
                attributes.insert(.addedFiles)
            case "R":
                attributes.insert(.renamedFiles)
            case "C":
                attributes.insert(.copiedFiles)
            case "D":
                attributes.insert(.deletedFiles)
            default:
                break
        }
    }
}
