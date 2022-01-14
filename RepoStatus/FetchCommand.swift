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
        var reposOrGroups: [String] = []

        @Flag(name: [.customLong("groups"), .customShort("g")],
              help: "Fetch the named groups, rather than repos")
        var areGroups = false


        mutating func validate() throws {
            let collection = RepoCollection(from: AppSettings.collectionStoreFileURL)

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
            let collection = RepoCollection(from: AppSettings.collectionStoreFileURL)
            let alignment = collection.lengthOfLongestRepoName()

            var groups: [RepoGroup]

            if reposOrGroups.isEmpty == false && areGroups == false {
                collection.concurrentlyForEach(in: nil, perform: {
                    if reposOrGroups.contains($0.name) {
                        $0.refresh()
                        if $0.fetch() == false {
                            $0.status.error = true
                        }
                    }
                })

                collection.forEach(in: nil,
                                   group: { print($0.name) },
                                   repo: {
                                    if reposOrGroups.contains($0.name) {
                                        $0.printStatus(alignmentColumn: alignment)
                                    }
                                   } )

            }
            else {
                if reposOrGroups.isEmpty {
                    groups = collection.groups
                }
                else {
                    groups = collection.groups(named: reposOrGroups)
                }
                
                collection.concurrentlyForEach(in: groups, perform: {
                    $0.refresh()
                    if $0.fetch() {
                        $0.refresh(fetching: false)
                    }
                    else {
                        $0.status.error = true
                    }
                })

                collection.forEach(in: groups,
                                   group: { print($0.name) },
                                   repo: { $0.printStatus(alignmentColumn: alignment) } )
            }
        }
    }
    
}

