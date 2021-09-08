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
        
        private func perform() throws {
            let collection = RepoCollection(from: RepoStatusCommand.configStoreFileURL)

            if collection.isEmpty {
                print("No repos defined")
                return
            }

            collection.forEachConcurrently { $0.refresh(fetching: fetch) }

            let alignment = longestRepoName(in: collection)

            collection.forEach { $0.printStatus(alignmentColumn: alignment) }
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
