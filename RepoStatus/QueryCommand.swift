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
            abstract: "Display status for configured Git repos")

        @Argument(help: "Display status for this group only")
        var groupName: String?

        @Flag(name: [.customLong("fetch"), .customShort("f")],
              help: "Fetches from remote before getting status")
        var fetch = false

        func run() throws {
            try perform()
        }
        
        private func append(_ string: String, if condition: Bool) -> String {
            return condition ? string : ""
        }
        
        private func perform() throws {
            let collection = RepoCollection(from: RepoStatusCommand.configStoreFileURL)

            if collection.isEmpty {
                print("Empty configuration")
                return
            }
            
            for group in collection.groups {
                
                if groupName == nil || (groupName != nil && groupName == group.name) {
                    print("\(group.name)".bold() + "".normal())
                    
                    for repo in group.repos {
                        printStatus(for: repo)
                    }
                }
            }
        }
        
        private func printStatus(for repo: Repo) {
            repo.refresh(fetching: fetch)
            
            var text = " \(repo.name): "
            
            if repo.status.isValid {
                if repo.status.contains(.modifiedFiles) {
                    text = text.background(.red3).colour(.white)
                }
                else if repo.status.contains(.addedFiles) {
                    text = text.background(.orange1)
                }
                else if repo.status.contains(.newUntrackedFiles) {
                    text = text.background(.yellow)
                }
                else {
                    text = text.background(.chartreuse2)
                }
                
                print("  " + text, terminator: "")
                
                var statusString = ""
                statusString += append("M ", if: repo.status.contains(.modifiedFiles))
                statusString += append("? ", if: repo.status.contains(.newUntrackedFiles))
                statusString += append("+ ", if: repo.status.contains(.addedFiles))
                statusString += append("S ", if: repo.status.contains(.hasStash))
                statusString += append("↑\(repo.status.aheadCount)", if: repo.status.aheadCount > 0)
                statusString += append("↓\(repo.status.behindCount)", if: repo.status.behindCount > 0)
                
                print(" \(statusString)" + "".normal() + " \(repo.status.branch) ".background(.silver) + " ".normal())
            }
            else {
                print("  \(repo.name): Invalid")
            }
        }
    }
}
