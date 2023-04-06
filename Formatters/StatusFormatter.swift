//
//  StatusFormatter.swift
//  RepoStatus
//
//  Created by Beavis, Simon on 4/04/23.
//

import Foundation

struct StatusFormatter {
    let details: StatusDetails

    init(for details: StatusDetails) {
        self.details = details
    }

    public var ansiFormatted: String {
        return output(using: appendFormatted)
    }

    public var plain: String {
        return output(using: append)
    }
}

// MARK: - Private

extension StatusFormatter {
    private func output(using appender: (String, Bool) -> String) -> String {
        var statusString = ""
        let aheadCount = details.aheadCount > 9 ? "+" : String(details.aheadCount)
        let behindCount = details.behindCount > 9 ? "+" : String(details.behindCount)

        statusString += appender("M ", details.contains(.modifiedFiles))
        statusString += appender("? ", details.contains(.newUntrackedFiles))

        if details.contains(.addedFiles) {
            print("!")
        }

        statusString += appender("+ ", details.contains(.addedFiles) || details.indexContains(.addedFiles))
        statusString += appender("S ", details.hasStash)
        statusString += appender("↑\(aheadCount)", details.aheadCount > 0)
        statusString += appender("↓\(behindCount)", details.behindCount > 0)

        if statusString.isEmpty {
            statusString = "- "
        }
        return statusString
    }


    private func appendFormatted(_ string: String, if condition: Bool) -> String {
        return condition ? string : "- ".dim().reset()
    }

    private func append(_ string: String, if condition: Bool) -> String {
        return condition ? string : "- "
    }

}
