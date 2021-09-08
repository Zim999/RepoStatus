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
            let alignment = longestRepoName(in: collection)

            if reposOrGroups.isEmpty {
                collection.forEachConcurrently {
                    $0.refresh()
                    if $0.pull() {
                        $0.refresh(fetching: false)
                    }
                    else {
                        $0.status.error = true
                    }
                }

                collection.forEach(group: { print($0.name) },
                                   repo: { $0.printStatus(alignmentColumn: alignment) } )
            }

            
// ...

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

        // ... Make common with one in QueryCommand
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

        func pull(repo: Repo) {
            // print("Pulling \(repo.name) ", terminator: "")

            repo.refresh()

            let indent = "  "

            //let branch = " \(repo.status.branch) ".background(ANSIColour.blueViolet).reset()

            print(indent +
                    " \(repo.name) " +
                    " \(repo.status.branch) ".background(.blueViolet).reset(),
                  terminator: "")

//            print(indent + "\(branch) ", terminator: "")
//            print(": ", terminator: "")

            if !repo.pull() {
                print(" ... " + "Error".colour(.red).reset())
            }
            else {
                print("")
            }
        }

        func pull(group: RepoGroup) {
            print("\(group.name)".bold().reset())
            for repo in group.repos {
                pull(repo: repo)
            }
        }

    }
    
}

