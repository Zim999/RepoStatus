//
//  Repo.swift
//  GitMonitor
//
//  Created by Simon Beavis on 10/18/20.
//

import Foundation

/// Represents a Git Repo
class Repo: Codable, RepoCollectionItem, ObservableObject {
    /// File URL for the repo directory
    let url : URL
    
    /// Unique identifier for this repo, preserved across app executions
    var id: UUID
    
    /// Status of the repo
    var status = Status()
    
    /// Display name for the repo
    var name: String {
        return url.deletingPathExtension().lastPathComponent
    }

    /// Initialise Repo with given local file URL
    /// - Parameter url: File URL of the local repo
    init(url: URL) {
        self.url = url
        self.id = UUID()
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
            status = Status() // Invalid
        }
        else {
            status = Status(from: statusOutput, stashList: stashOutput)
        }
    }

    /// Perform a git fetch on the repo
    /// - Returns: Fetch command exit code. 0 if command executed successfully, non-zero for errors
    func fetch() -> Bool {
        return perform(command: Git.fetchCommand)
    }

    /// Perform a git pull on the repo
    /// - Returns: Pull command exit code. 0 if command executed successfully, non-zero for errors
    func pull() -> Bool {
        return perform(command: Git.pullCommand)
    }

    /// Output the status of the repo to stdout. The beginning of the line has the repo name,
    /// then alignment column is used to indent the status information.
    /// - Parameter alignmentColumn: Screen column where the status is output.
    func printSummary(alignmentColumn: Int) {
        let output = RepoSummaryFormatter(for: self, alignmentColumn: alignmentColumn)
        print(output.ansiFormatted)
    }
}

extension Repo: Equatable {
    static func == (lhs: Repo, rhs: Repo) -> Bool {
        return lhs.name == rhs.name
    }
}

// MARK: - Static Functions

extension Repo {

    public static func exists(at url: URL) -> Bool {
        let (exitCode, _) = Shell.run(Git.statusCommand, at: url)
        return exitCode == 0
    }

    public static func repos(at url: URL) throws -> [URL]? {
        var results = [URL]()

        let urls = try FileManager.default.contentsOfDirectory(at: url,
                                                               includingPropertiesForKeys: nil)

        for u in urls {
            if Repo.exists(at: u) {
                results.append(u)
            }
        }

        return results.count > 0 ? results : nil
    }
    
}

// MARK: - Private Functions

extension Repo {
    private enum CodingKeys: String, CodingKey {
        case url
        case id
    }

    /// Perform a git command on the repo
    /// - Returns: Command exit code. 0 if command executed successfully, non-zero for errors
    private     func perform(command: String) -> Bool {
        let (exitCode, output) = Shell.run(command, at: url)

        let newStatus = status
        newStatus.errorMessage = ""

        if let out = output,
           out.contains("error:") {
            newStatus.errorMessage = extractError(from: out).capitalized
        }
        else if exitCode > 0 {
            newStatus.errorMessage = "Error Executing Command"
        }
        else {
            refresh()
        }

        newStatus.error = exitCode != 0

        status = newStatus

        return !status.error
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

