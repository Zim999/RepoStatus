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
            abstract: "Performs a Git pull on all or specified repos, or all repos in specified groups")

        @Argument(help: "Repos, or groups if -g option is used, to pull")
        var reposOrGroups: [String] = []

        @Flag(name: [.customLong("group"), .customShort("g")],
              help: "Pull the named groups, rather than repos")
        var areGroups = false


        mutating func validate() throws {
//            guard !reposOrGroups.isEmpty else {
//                throw ValidationError("No groups specified")
//            }

            let collection = RepoCollection(from: RepoStatusCommand.configStoreFileURL)

            for item in reposOrGroups {
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

            if reposOrGroups.isEmpty {
                for group in collection.groups {
                    pull(group: group)
                }
            }
            else {
            }

            for item in reposOrGroups {
                if areGroups,
                   let group = collection.group(named: item) {
                    pull(group: group)
                }
                else if let repos = collection.repos(named: item) {
                    repos.forEach { (repo) in
                        pull(repo: repo)
                    }
                }
            }
        }

        func pull(repo: Repo) {
            print("Pulling \(repo.name) ", terminator: "")

            repo.refresh()

            let branch = " \(repo.status.branch) ".background(ANSIColour.blueViolet).reset()
            print("\(branch) ", terminator: "")
            print(": ", terminator: "")

            if !repo.pull() {
                print("Error".colour(.red).reset())
            }
            else {
                print("Done")
            }
        }

        func pull(group: RepoGroup) {
            print ("Group: \(group.name)")
            for repo in group.repos {
                pull(repo: repo)
            }
        }

    }
    
}
