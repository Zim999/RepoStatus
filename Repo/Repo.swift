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

    /// Initialise Repo with given local file URL
    /// - Parameter url: File URL of the local repo
    init(url: URL) {
        self.url = url
        self.uuid = UUID()
    }

    /// Refresh the status of the repo by executing the  git status command. Can also optionally
    /// fetch status from remotes
    /// - Parameter fetching: If true, fetch from remotes before updating the status
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

    /// Perform a git pull on the repo
    /// - Returns: Pull command exit code. 0 if command executed successfully, non-zero for errors
    func pull() -> Bool {
        let (exitCode, output) = Shell.run(Git.pullCommand, at: url)

        status.errorMessage = ""

        if let out = output,
           out.contains("error:") {
            status.errorMessage = extractError(from: out).capitalized
        }
        else {
            refresh()
        }

        return exitCode == 0
    }

    /// Output the status of the repo to stdout. The beginning of the line has the repo name,
    /// then alignment column is used to indent the status information.
    /// - Parameter alignmentColumn: Screen column where the status is output.
    func printStatus(alignmentColumn: Int) {
        let indent = "  "
        let align = alignmentColumn + 1 - name.count
        let statusColour = statusColours(from: status)

        if status.error {
            print(indent +
                    "\(statusColour)" +
                    " \(name) ".forward(align).colours(.black, .red).reset())
            print("  " + " Error:\(status.errorMessage) ".colours(.black, .red).reset())
        }
        else if status.isValid {
            let statusString = status.asString

            print(indent +
                  "\(statusColour)" +
                  " \(name) ".reset().forward(align) +
                  " \(statusString) " +
                  " \(status.branch) ".background(.blueViolet).reset())
        }
        else {
            print(indent +
                    "\(statusColour)" +
                    " \(name) ".reset().forward(align) +
                    " Invalid Repo ".colours(.black, .orange1).reset())
        }
    }
}

extension Repo: Equatable {
    static func == (lhs: Repo, rhs: Repo) -> Bool {
        return lhs.name == rhs.name
    }
}

// MARK: - Static Functions

extension Repo {
    public static func exists(at path: String) -> Bool {
        let (exitCode, _) = Shell.run(Git.statusCommand, at: URL(fileURLWithPath: path))
        return exitCode == 0
    }
}

// MARK: - Private Functions

extension Repo {
    private enum CodingKeys: String, CodingKey {
        case url
        case uuid
    }

    private func statusColours(from status: RepoStatus) -> String {
        var statusColour = ""

        if status.error {
            statusColour = statusColour.colours(.white, .red3)
        }
        else if status.contains(.modifiedFiles) {
            statusColour = statusColour.colours(.black, .orange1)
        }
        else if status.contains(.addedFiles) || status.indexContains(.addedFiles) {
            statusColour = statusColour.colours(.black, .yellow)
        }
        else if status.contains(.newUntrackedFiles) {
            statusColour = statusColour.colours(.white, .fuchsia)
        }
        else {
            statusColour = statusColour.colours(.darkGreen, .greenYellow)
        }

        return statusColour
    }

    private func extractError(from errorString: String) -> String {
        var output = ""

        do {
            let regex = try NSRegularExpression(pattern: "error:(.+)")
            let matches = regex.matches(in: errorString,
                                        options: [],
                                        range: NSRange(location: 0, length: errorString.count))

            for match in matches {
                if match.numberOfRanges > 1 {
                    output +=  errorString.subString(range: match.range(at: 1))
                }
            }
        }
        catch {
            print("Exception parsing error")
        }

        return output
    }
}

