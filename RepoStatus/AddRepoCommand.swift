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
            abstract: "Add a repo, or all repos in a directory",
            discussion:
                """
                If the specified path is a repo, that repo is added.
                If the specified path is a directory, all repos found at the path (top-level only) will be added.
                """)
        
        @Argument(help: "Local file path of the repo, or a directory containing repos")
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
                throw ValidationError("Path is not a directory")
            }

//            guard Repo.exists(at: repoPath) else {
//                throw ValidationError("Path is not a Git repo")
//            }
        }
        
        func run() throws {
            let collection = RepoCollection(from: AppSettings.collectionStoreFileURL)

            let nameOfGroupToUse = groupName ?? RepoCollection.DefaultGroupName
            var group = collection.group(named: nameOfGroupToUse)

            if group == nil {
                group = RepoGroup(name: nameOfGroupToUse)
                collection.add(group!)
            }

            guard group != nil else {
                throw ValidationError("Could not add repo")
            }

            let url = URL(fileURLWithPath: repoPath)

            if Repo.exists(at: url) {
                let repo = Repo(url: url)
                collection.add(repo, to: group!)
            }
            else {
                // Add all repos within the passed in directory

                guard let urls = try Repo.repos(at: url) else {
                    throw ValidationError("No repos found at path")
                }

                for url in urls {
                    let repo = Repo(url: url)
                    collection.add(repo, to: group!)
                }
            }
        }

        private func directoryExists(at path: String) -> Bool {
            return FileManager.default.directoryExists(URL(fileURLWithPath: path))
        }
    }
}
