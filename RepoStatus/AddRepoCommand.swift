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
        
        @Argument(help: "Name of the group to add to")
        var groupName: String
        
        mutating func validate() throws {
            repoPath.trim()
            groupName.trim()
            
            guard !repoPath.isEmpty else {
                throw ValidationError("Repo name cannot be empty")
            }

            guard !groupName.isEmpty else {
                throw ValidationError("Group name cannot be empty")
            }

            guard Repo.exists(at: repoPath) else {
                throw ValidationError("Path is not a Git repo")
            }
        }
        
        func run() throws {
            let collection = RepoCollection(from: RepoStatusCommand.configStoreFileURL)

            guard let group = collection.group(named: groupName) else {
                throw ValidationError("Group does not exist")
            }
            
            let repo = Repo(url: URL(fileURLWithPath: repoPath))
            collection.add(repo, to: group)
        }
    }
}
