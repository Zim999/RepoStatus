//
//  RemoveGroupCommand.swift
//  RepoStatus
//
//  Created by Simon Beavis on 30/12/20.
//

import Foundation
import ArgumentParser

extension RepoStatusCommand {
    struct RemoveGroup: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "removegroup",
            abstract: "Remove group, and all contained repos")
        
        @Argument(help: "Name of the group to remove")
        var groupName: String
        
        func validate() throws {
            guard !groupName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            else { throw ValidationError("Repo name cannot be empty") }

            let collection = RepoCollection(from: AppSettings.collectionStoreFileURL)

            guard let _ = collection.group(named: groupName)
            else { throw ValidationError("Group does not exist") }
        }
        
        func run() throws {
            let collection = RepoCollection(from: AppSettings.collectionStoreFileURL)

            guard let group = collection.group(named: groupName)
            else { throw ValidationError("Group does not exist") }

            collection.remove(group)
        }
    }
}
