//
//  Status.swift
//  GitMonitor
//
//  Created by Simon Beavis on 10/18/20.
//

import Foundation

struct StatusDetails {
    /// Current attributes of the working copy
    var workingCopyAttributes = AttributeSet()

    /// Current attributes of the index
    var indexAttributes = AttributeSet()

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

    public func contains(_ attribute: Attribute) -> Bool {
        return workingCopyAttributes.contains(attribute)
    }

    public func indexContains(_ attribute: Attribute) -> Bool {
        return indexAttributes.contains(attribute)
    }
}

/// Represents status of a Git Rrepo
class Status {

    var details = StatusDetails()

    /// Did last command return error
    var error = false

    /// Last error if command return error
    var errorMessage = ""

    /// Status formatted into a plain string
    var asString: String {
        return StatusFormatter(for: details).plain
    }

    /// Status formatted into a formatted string
    var asFormattedString: String {
        return StatusFormatter(for: details).ansiFormatted
    }

    init() { }
    
    /// Create an instance of Status, from the output of the git status command
    /// - Parameters:
    ///   - statusLines: Output from th git status command
    ///   - stashList: Output from the git stash lst command
    init(from statusLines: String?, stashList: String?) {
        guard let statusLines, !statusLines.isEmpty else { return }
        
        if let newDetails = parse(statusLines) {
            details = newDetails
        }
        details.hasStash = (stashList?.count ?? 0) > 0
    }

    private func parse(_ statusLines: String) -> StatusDetails? {
        let lines = statusLines.split(separator: "\n")
        var parser = StatusParser(lines)

        do {
            return try parser.parse()
        }
        catch {
            print("Exception in Status init \(error)")
            self.error = true
        }

        return nil
    }
}
