//
//  RemoveRepoCommand.swift
//  RepoStatus
//
//  Created by Simon Beavis on 30/12/20.
//

import Foundation
import ArgumentParser

extension RepoStatusCommand {
    struct RemoveRepo: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "removerepo",
            abstract: "Remove the named repo from the list, from either a single or all groups")
        
        @Argument(help: "Name of the repo")
        var repoName: String

        @Option(name: [.customShort("g"), .customLong("group")],
                help: "Name of the group to remove the repo from")
        var groupName: String?

        func validate() throws {
            guard !repoName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else { throw ValidationError("Repo name cannot be empty") }
        }
        
        func run() throws {
            let collection = RepoCollection(from: AppSettings.collectionStoreFileURL)

            if let groupName = groupName {
                guard let group = collection.group(named: groupName) else {
                    throw ValidationError("Group does not exist")
                }

                if let repo = group.repo(named: repoName) {
                    group.remove(repo)
                }
                else {
                    throw ValidationError("Repo not in specified group")
                }
            }
            else {
                for group in collection.groups {
                    if let repo = group.repo(named: repoName) {
                        collection.remove(repo)
                    }
                }
            }

            collection.purgeEmptyGroups()
        }
    }
}
