//
//  Repo.swift
//  GitMonitor
//
//  Created by Simon Beavis on 10/18/20.
//

import Foundation

/// Represents a Git Repo
class Repo: Codable, RepoCollectionItem {
    /// File URL for the repo directory
    let url : URL
    
    /// Unique identifier for this repo, preserved across app executions
    var uuid: UUID
    
    /// Status of the repo
    var status = RepoStatus()
    
    /// Display name for the repo
    var name: String {
        return url.deletingPathExtension().lastPathComponent
    }
    
    init(url: URL) {
        self.url = url
        self.uuid = UUID()
    }
    
    /// Refresh the status of the repo
    func refresh(fetching: Bool = false) {
        if fetching {
            let (_, _) = Shell.run(Git.fetchCommand, at: url)
        }
        
        let (exitCode, statusOutput) = Shell.run(Git.statusCommand, at: url)
        let (_, stashOutput) = Shell.run(Git.stashListCommand, at: url)

        if exitCode != 0 {
            status = RepoStatus() // Invalid
        }
        else {
            status = RepoStatus(from: statusOutput, stashList: stashOutput)
        }
    }

    func pull() -> Bool {
        let (exitCode, _) = Shell.run(Git.pullCommand, at: url)
        // .. parse status
        refresh()
        return exitCode == 0
    }
}

extension Repo: Equatable {
    static func == (lhs: Repo, rhs: Repo) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Repo {
    private enum CodingKeys: String, CodingKey {
        case url
        case uuid
    }
}

extension Repo {
    public func printStatus(alignmentColumn: Int) {
        let indent = "  "
        if status.error {
            print(indent + "\(name): " + "Error".colours(.black, .red).reset())

        }
        else if status.isValid {
            let statusString = status.asString
            let statusColour = statusColours(from: status)
            let align = alignmentColumn + 1 - name.count

            print(indent +
                  "\(statusColour)" +
                  " \(name) ".reset().forward(align) +
                  " \(statusString) " +
                  " \(status.branch) ".background(.blueViolet).reset())
        }
        else {
            print(indent + "\(name): " + "Invalid Repo".colours(.black, .orange1).reset())
        }
    }

    private func statusColours(from status: RepoStatus) -> String {
        var statusColour = ""

        if status.contains(.modifiedFiles) {
            statusColour = statusColour.colours(.white, .red3)
        }
        else if status.contains(.addedFiles) {
            statusColour = statusColour.colours(.black, .orange1)
        }
        else if status.contains(.newUntrackedFiles) {
            statusColour = statusColour.colours(.black, .yellow)
        }
        else {
            statusColour = statusColour.colours(.darkGreen, .greenYellow)
        }

        return statusColour
    }
}

// MARK: - Static Functions

extension Repo {
    public static func exists(at path: String) -> Bool {
        let (exitCode, _) = Shell.run(Git.statusCommand, at: URL(fileURLWithPath: path))
        return exitCode == 0
    }
}
