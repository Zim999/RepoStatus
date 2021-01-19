//
//  PullCommand.swift
//  RepoStatus
//
//  Created by Beavis, Simon on 19/1/21.
//

import Foundation
import ArgumentParser

extension RepoStatusCommand {

    struct Pull: ParsableCommand {

        static let configuration = CommandConfiguration(
            commandName: "pull",
            abstract: "Performs a Git pull on all configured repos, a specified group of repos, or a single repo")

        @Argument(help: "Repos, or groups if -g option is used, to pull")
        var toPull: [String] = []

        @Flag(name: [.customLong("group"), .customShort("g")],
              help: "Pull the named groups, rather than repos")
        var areGroups = false


        mutating func validate() throws {
            guard !toPull.isEmpty else {
                throw ValidationError("No repos or groups defined")
            }

            let collection = RepoCollection(from: RepoStatusCommand.configStoreFileURL)

            for item in toPull {
                if areGroups {
                    guard collection.group(named: item) != nil else {
                        throw ValidationError("No such group \(item)")
                    }
                }
                else {
                    guard collection.repos(named: item) != nil else {
                        throw ValidationError("No such repo \(item)")
                    }
                }
            }
        }

        func run() throws {
            let collection = RepoCollection(from: RepoStatusCommand.configStoreFileURL)

            for item in toPull {
                if areGroups,
                   let group = collection.group(named: item) {
                    try pull(group: group)
                }
                else if let repos = collection.repos(named: item) {
                    try repos.forEach { (repo) in
                        try pull(repo: repo)
                    }
                }
                else {
                    // ...
                }
            }
        }

        func pull(repo: Repo) throws {
            print("Pulling \(repo.name) ... ", terminator: "")
            if !repo.pull() {
                throw ValidationError("Error")
            }
            else {
                print("Done")
            }
        }

        func pull(group: RepoGroup) throws {
            for repo in group.repos {
                try pull(repo: repo)
            }
        }

    }
    
}
