//
//  AddRepoCommand.swift
//  RepoStatus
//
//  Created by Simon Beavis on 30/12/20.
//

import Foundation
import ArgumentParser

extension RepoStatusCommand {
    struct AddRepo: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "addrepo",
            abstract: "Add a repo to a group within the collection")
        
        @Argument(help: "Local file path of the repo")
        var repoPath: String

        @Option(name: [.customShort("g"), .customLong("group")],
                help: "Name of the group to add to, otherwise Default is used")
        var groupName: String?

        mutating func validate() throws {
            repoPath.trim()

            if let groupName = groupName?.trimmed() {
                guard !groupName.isEmpty else {
                    throw ValidationError("Group name cannot be empty")
                }
            }

            guard !repoPath.isEmpty else {
                throw ValidationError("Repo name cannot be empty")
            }

            guard directoryExists(at: repoPath) else {
                throw ValidationError("Path is not a Git repo")
            }

            guard Repo.exists(at: repoPath) else {
                throw ValidationError("Path is does not exist")
            }
        }
        
        func run() throws {
            let collection = RepoCollection(from: RepoStatusCommand.configStoreFileURL)

            let nameOfGroupToUse = groupName ?? RepoCollection.DefaultGroupName
            var group = collection.group(named: nameOfGroupToUse)

            if group == nil {
                group = RepoGroup(name: nameOfGroupToUse)
                collection.add(group!)
            }

            guard group != nil else {
                throw ValidationError("Could not add repo")
            }

            let repo = Repo(url: URL(fileURLWithPath: repoPath))
            collection.add(repo, to: group!)
        }

        private func directoryExists(at path: String) -> Bool {
            return FileManager.default.directoryExists(URL(fileURLWithPath: path))
        }
    }
}
