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
    }
    
    typealias AttributeSet = Set<Attribute>
    
    /// Current attributes of the working copy
    var workingCopyAttributes = AttributeSet()

    /// Current attributes of the index
    var indexAttributes = AttributeSet()

    /// Did last command return error
    var error = false

    /// Last error if command return error
    var errorMessage = ""

    /// Has valid status been retrieved about the repo
    var isValid = false
    
    /// Number of commits ahead working copy is compared to remote
    var aheadCount = 0

    /// Number of commits behind working copy is compared to remote
    var behindCount = 0
    
    /// Current branch
    var branch = "..."

    /// Working copy has stashed code
    var hasStash = false

    /// Status formatted into a string
    var asString: String {
        return asFormattedString()
    }

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

                hasStash = (stashList?.count ?? 0) > 0
                
                isValid = true
            }
        }
        catch {
            print("Exception in RepoStatus init \(error)")
            self.error = true
        }
    }

    public func contains(_ attribute: Attribute) -> Bool {
        return workingCopyAttributes.contains(attribute)
    }

    public func indexContains(_ attribute: Attribute) -> Bool {
        return indexAttributes.contains(attribute)
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
                set(in: &indexAttributes, from: firstValue)
                
                let secondValue = string.subString(range: match.range(at: 2))
                set(in: &workingCopyAttributes, from: secondValue)
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
        let count = try getIntMatchValue(from: string, using: ".+\\[ahead\\s+([0-9]+)\\]")
        if count > 0 {
            aheadCount = count
            // workingCopyAttributes.insert(.ahead)
        }
    }
    
    private func getBehindCount(from string: String) throws {
        let count = try getIntMatchValue(from: string, using: ".+\\[behind\\s+([0-9]+)\\]")
        if count > 0 {
            behindCount = count
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

extension RepoStatus {
    private func asFormattedString() -> String {
        var statusString = ""
        let aheadCount = aheadCount > 9 ? "+" : String(aheadCount)
        let behindCount = behindCount > 9 ? "+" : String(behindCount)

        statusString += append("M ", if: contains(.modifiedFiles))
        statusString += append("? ", if: contains(.newUntrackedFiles))

        if contains(.addedFiles) {
            print("!")
        }

        statusString += append("+ ", if: contains(.addedFiles) || indexContains(.addedFiles))
        statusString += append("S ", if: hasStash)
        statusString += append("↑\(aheadCount)", if: self.aheadCount > 0)
        statusString += append("↓\(behindCount)", if: self.behindCount > 0)

        if statusString.isEmpty {
            statusString = "- "
        }
        return statusString
    }

    private func append(_ string: String, if condition: Bool) -> String {
        return condition ? string : "- ".dim().reset()
    }
}
