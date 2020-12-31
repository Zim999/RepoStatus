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
            abstract: "Remove a repo")
        
        @Argument(help: "Name of the repo")
        var repoName: String
        
        @Argument(help: "Name of the containing group")
        var groupName: String
        
        func validate() throws {
            guard !repoName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                  !groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else {
                throw ValidationError("Repo and group names cannot be empty")
            }
            
            guard let group = collection.group(named: groupName) else {
                throw ValidationError("Group does not exist")
            }
            
            guard group.repo(named: repoName) != nil else {
                throw ValidationError("Repo not in specified group")
            }
        }
        
        func run() throws {
            guard let group = collection.group(named: groupName) else {
                throw ExitCode.failure
            }
            
            if let repo = group.repo(named: repoName) {
                group.remove(repo)
            }
        }
    }
}
