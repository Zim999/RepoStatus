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
        var toPull: [String] = []

        @Flag(name: [.customLong("groups"), .customShort("g")],
              help: "Pull the named groups, rather than repos")
        var pullingGroups = false

        mutating func validate() throws {
            let collection = RepoCollection(from: AppSettings.collectionStoreFileURL)

            for item in toPull {
                if pullingGroups {
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
            let pullingRepos = toPull.isEmpty == false && pullingGroups == false

            pullingRepos ? run(onRepos: toPull) : run(onGroups: toPull)
        }

        private func run(onRepos: [String]) {
            let collection = RepoCollection(from: AppSettings.collectionStoreFileURL)
            let alignment = collection.lengthOfLongestRepoName()

            collection.concurrentlyForEach(in: nil, perform: {
                if toPull.contains($0.name) {
                    run(onRepo: $0)
                }
            })

            collection.forEach(in: nil,
                               group: { print("\($0.name) (\($0.repos.count))") },
                               perform: {
                if toPull.contains($0.name) {
                    $0.printSummary(alignmentColumn: alignment)
                }
            } )
        }

        private func run(onGroups: [String]) {
            let collection = RepoCollection(from: AppSettings.collectionStoreFileURL)
            let alignment = collection.lengthOfLongestRepoName()

            let groups = toPull.isEmpty ? collection.groups : collection.groups(named: toPull)

            collection.concurrentlyForEach(in: groups, perform: {
                run(onRepo: $0)
            })

            collection.forEach(in: groups,
                               group: { print("\($0.name) (\($0.repos.count))") },
                               perform: { $0.printSummary(alignmentColumn: alignment) } )
        }

        private func run(onRepo repo: Repo) {
            repo.refresh()
            if repo.status.details.isValid {
                //                if repo.pull() == false {
                //                    repo.status.error = true
                //                }
                if repo.pull() {
                    repo.refresh(fetching: false)
                }
                else {
                    repo.status.error = true
                }
            }
            else {
                repo.status.errorMessage = " Invalid Repo"
                repo.status.error = true
            }
        }
    }
}

