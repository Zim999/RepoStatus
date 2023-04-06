//
//  RepoSummaryFormatter.swift
//  RepoStatus
//
//  Created by Beavis, Simon on 4/04/23.
//

import Foundation

struct RepoSummaryFormatter {
    let repo: Repo
    let alignmentColumn: Int

    init(for repo: Repo, alignmentColumn: Int) {
        self.repo = repo
        self.alignmentColumn = alignmentColumn
    }

    var ansiFormatted: String {
        var output = ""

        let MaxErrorLength = 50
        let indent = "  "
        let align = alignmentColumn + 1 - repo.name.count
        let statusColour = statusColours(from: repo.status)

        output = indent +
                 "\(statusColour)"

        if repo.status.error {
            var errorMessage = repo.status.errorMessage
            if errorMessage.count > MaxErrorLength {
                errorMessage = errorMessage.prefix(MaxErrorLength) + "..."
            }

            output += " \(repo.name) " +
                      "\(statusColour)" +
                      "\(errorMessage) ".colours(.yellow, .red).reset()
        }
        else if repo.status.details.isValid {
            let statusString = repo.status.asFormattedString

            output += " \(repo.name) ".reset().forward(align) +
                      " \(statusString) " +
                      " \(repo.status.details.branch) ".background(.blueViolet).reset()
        }
        else {
            output += " \(repo.name) ".reset().forward(align) +
                      " Invalid Repo ".colours(.black, .orange1).reset()
        }

        return output
    }

    private func statusColours(from status: Status) -> String {
        var statusColour = ""

        if status.error {
            statusColour = statusColour.colours(.white, .red3)
        }
        else if status.details.contains(.modifiedFiles) {
            statusColour = statusColour.colours(.black, .orange1)
        }
        else if status.details.contains(.addedFiles) || status.details.indexContains(.addedFiles) {
            statusColour = statusColour.colours(.black, .yellow)
        }
        else if status.details.contains(.newUntrackedFiles) {
            statusColour = statusColour.colours(.white, .fuchsia)
        }
        //        else {
        //            statusColour = statusColour.colours(.darkGreen, .greenYellow)
        //        }

        return statusColour
    }
}
