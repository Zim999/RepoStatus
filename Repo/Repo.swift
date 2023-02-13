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
    @Published var status = Status()
    
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

        // ... Needs to be sorted out
        #if COMMANDLINE
        if exitCode != 0 {
            status = Status() // Invalid
        }
        else {
            status = Status(from: statusOutput, stashList: stashOutput)
        }
        #else

        DispatchQueue.main.async {
            if exitCode != 0 {
                self.status = Status() // Invalid
            }
            else {
                self.status = Status(from: statusOutput, stashList: stashOutput)
            }
        }
        #endif
    }

//    func refreshAsync(fetching: Bool = false) async {
//        await withCheckedContinuation({ continuation in
//            refresh(fetching: fetching)
//            continuation.resume()
//        })
//    }
    
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
    func printStatus(alignmentColumn: Int) {
        let MaxErrorLength = 50
        let indent = "  "
        let align = alignmentColumn + 1 - name.count
        let statusColour = statusColours(from: status)

        if status.error {
            var errorMessage = status.errorMessage
            if errorMessage.count > MaxErrorLength {
                errorMessage = errorMessage.prefix(MaxErrorLength) + "..."
            }

            print(indent +
                  "\(statusColour)" +
                  " \(name) " +
                  "\(statusColour)" +
                  "\(errorMessage) ".colours(.yellow, .red).reset())
        }
        else if status.isValid {
            let statusString = status.asFormattedString

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
    private func perform(command: String) -> Bool {
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
        
        runOnMain {
            status = newStatus
        }

        return !status.error
    }
    
    private func statusColours(from status: Status) -> String {
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
//        else {
//            statusColour = statusColour.colours(.darkGreen, .greenYellow)
//        }

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
    
    private func runOnMain(_ f: () -> Void) {
        if Thread.isMainThread {
            f()
        }
        else {
            DispatchQueue.main.sync {
                f()
            }
        }
    }
}

