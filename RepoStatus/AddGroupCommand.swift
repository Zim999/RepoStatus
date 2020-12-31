//
//  AddGroupCommand.swift
//  RepoStatus
//
//  Created by Simon Beavis on 30/12/20.
//

import Foundation
import ArgumentParser

extension RepoStatusCommand {
    

    struct AddGroup: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "addgroup",
            abstract: "Add a new group to the collection")
        
        @Argument(help: "Name of the group.")
        var groupName: String
        
        mutating func validate() throws {
            groupName.trim()
            
            guard !groupName.isEmpty else {
                throw ValidationError("Group name cannot be empty")
            }
            
            guard !collection.contains(groupName) else {
                throw ValidationError("Group already exists")
            }
        }
        
        func run() throws {
            collection.add(RepoGroup(name: groupName))
        }
    }
}

