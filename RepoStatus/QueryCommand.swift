//
//  QueryCommand.swift
//  RepoStatus
//
//  Created by Simon Beavis on 30/12/20.
//

import Foundation
import ArgumentParser

extension RepoStatusCommand {
    struct Query: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract:"""
Display status for configured Git repos

    Repo name coloured as follows (priority order):
        red = Repo has modified files
        orange = Repo has added files
        yellow = Repo has untracked files
        green = Repo clean, no changes

    Repo status flags:
        + = Files added
        M = Files modified
        ? = New untracked files
        S = Has stashed changes
        ↑ = Ahead of remote
        ↓ = Behind remote
""")

        @Argument(help: "Display status for this group only")
        var groupName: String?

        @Flag(name: [.customLong("fetch"), .customShort("f")],
              help: "Fetches from remote before getting status")
        var fetch = false

        func run() throws {
            try perform()
        }
        
        private func append(_ string: String, if condition: Bool) -> String {
            return condition ? string : "- ".dim().reset()
        }
        
        private func perform() throws {
            let collection = RepoCollection(from: RepoStatusCommand.configStoreFileURL)

            if collection.isEmpty {
                print("Empty configuration")
                return
            }
            
            let lengthOfLongest = longestRepoName(in: collection)

            for group in collection.groups {
                if groupName == nil || (groupName != nil && groupName == group.name) {
                    print("\(group.name)".bold().reset())
                    
                    for repo in group.repos {
                        printStatus(for: repo, longest: lengthOfLongest)
                    }
                }
            }
        }
        
        private func status(from status: RepoStatus) -> String {
            var statusString = ""
            let aheadCount = status.aheadCount > 9 ? "+" : String(status.aheadCount)
            let behindCount = status.behindCount > 9 ? "+" : String(status.behindCount)

            statusString += append("M ", if: status.contains(.modifiedFiles))
            statusString += append("? ", if: status.contains(.newUntrackedFiles))
            statusString += append("+ ", if: status.contains(.addedFiles))
            statusString += append("S ", if: status.hasStash)
            statusString += append("↑\(aheadCount)", if: status.aheadCount > 0)
            statusString += append("↓\(behindCount)", if: status.behindCount > 0)
            
            if statusString.isEmpty {
                statusString = "- "
            }
            return statusString
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
                statusColour = statusColour.colours(.black, .chartreuse2)
            }
            
            return statusColour
        }
        
        private func printStatus(for repo: Repo, longest: Int) {
            repo.refresh(fetching: fetch)
            
            let indent = "  "
            if repo.status.isValid {
                let statusString = status(from: repo.status)
                let statusColour = statusColours(from: repo.status)
                let align = longest + 1 - repo.name.count
                
                print(indent +
                      "\(statusColour)" +
                      " \(repo.name) ".reset().forward(align) +
                      " \(statusString) " +
                      " \(repo.status.branch) ".background(.steelBlue1_2).reset())
            }
            else {
                print(indent + "\(repo.name): " + "Invalid Repo".colours(.black, .orange1).reset())
            }
        }
        
        private func longestRepoName(in collection: RepoCollection) -> Int {
            var longest = 0

            for group in collection.groups {
                for repo in group.repos {
                    if repo.name.count > longest {
                        longest = repo.name.count
                    }
                }
            }
            return longest
        }
    }
}
