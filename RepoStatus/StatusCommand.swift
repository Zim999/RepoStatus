//
//  StatusCommand.swift
//  RepoStatus
//
//  Created by Simon Beavis on 30/12/20.
//

import Foundation
import ArgumentParser

extension RepoStatusCommand {
    struct Status: ParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Display status of repos. Use --fetch option to fetch from remotes first",
            discussion: """
                Display status for configured Git repos. Use --fetch option to fetch from remotes first

                Repo name coloured as follows (priority order):
                    red = Git command failed
                    orange = Repo has modified files
                    yellow = Repo has added files
                    fuchsia = Repo has untracked files

                Repo status flags:
                    + = Files added
                    M = Files modified
                    ? = New untracked files
                    S = Has stashed changes
                    ↑ = Ahead of remote
                    ↓ = Behind remote
            """)

        @Argument(help: "Display status for this repo only")
        var repoName: String?

        @Flag(name: [.customLong("fetch"), .customShort("f")],
              help: "Fetches from remote before getting status")
        var fetch = false

        @Flag(name: [.customLong("verbose"), .customShort("v")],
              help: "Show more information about each repo")
        var verbose = false

        func run() throws {
            try perform()
        }
        
        private func perform() throws {
            let collection = RepoCollection(from: AppSettings.collectionStoreFileURL)

            if collection.isEmpty {
                print("No repos defined")
                return
            }

            collection.concurrentlyForEach(in: nil,
                                           perform: {
                if repoName == nil || $0.name == repoName {
                    $0.refresh(fetching: fetch)
                }
            })

            let alignment = collection.lengthOfLongestRepoName()

            collection.forEach(in: nil,
                               group: {
                if repoName == nil {
                    print($0.name.bold().reset())                    
                } },
                               perform: {
                if repoName == nil || $0.name == repoName {
                    $0.printSummary(alignmentColumn: alignment)
                    if verbose {
                        print("    Path: \($0.url.path)")
                    }
                }
            })
        }
    }
}
