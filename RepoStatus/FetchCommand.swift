//
//  FetchCommand.swift
//  RepoStatus
//
//  Created by Beavis, Simon on 19/1/21.
//

import Foundation
import ArgumentParser

extension RepoStatusCommand {

    struct Fetch: ParsableCommand {

        static let configuration = CommandConfiguration(
            commandName: "fetch",
            abstract: "Performs a Git fetch on all or specified repos, or all repos in specified groups")

        @Argument(help: "Repos, or groups if -g option is used, to fetch")
        var toFetch: [String] = []

        @Flag(name: [.customLong("groups"), .customShort("g")],
              help: "Fetch the named groups, rather than repos")
        var fetchingGroups = false


        mutating func validate() throws {
            let collection = RepoCollection(from: AppSettings.collectionStoreFileURL)

            for item in toFetch {
                if fetchingGroups {
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
            let fetchingRepos = toFetch.isEmpty == false && fetchingGroups == false

            fetchingRepos ? run(onRepos: toFetch) : run(onGroups: toFetch)
        }

        private func run(onRepos: [String]) {
            let collection = RepoCollection(from: AppSettings.collectionStoreFileURL)
            let alignment = collection.lengthOfLongestRepoName()

            collection.concurrentlyForEach(in: nil, perform: {
                if toFetch.contains($0.name) {
                    run(onRepo: $0)
                }
            })

            collection.forEach(in: nil,
                               group: { print($0.name) },
                               perform: {
                if toFetch.contains($0.name) {
                    $0.printStatus(alignmentColumn: alignment)
                }
            } )
        }

        private func run(onGroups: [String]) {
            let collection = RepoCollection(from: AppSettings.collectionStoreFileURL)
            let alignment = collection.lengthOfLongestRepoName()

            let groups = toFetch.isEmpty ? collection.groups : collection.groups(named: toFetch)

            collection.concurrentlyForEach(in: groups, perform: {
                run(onRepo: $0)
            })

            collection.forEach(in: groups,
                               group: { print($0.name) },
                               perform: { $0.printStatus(alignmentColumn: alignment) } )
        }

        private func run(onRepo repo: Repo) {
            repo.refresh()
            if repo.status.isValid {
                if repo.fetch() {
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

