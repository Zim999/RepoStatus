//
//  main.swift
//  RepoStatusCommand
//
//  Created by Simon Beavis on 10/5/20.
//

import Foundation
import ArgumentParser

let VersionNumberString = "0.1.0"

RepoStatusCommand.main()

struct RepoStatusCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "RepoStatus",
        abstract: "Display status of Git Repositories",
        version: VersionNumberString,
        subcommands: [Query.self,
                      Config.self,
                      Key.self,
                      AddGroup.self,
                      AddRepo.self,
                      RemoveGroup.self,
                      RemoveRepo.self,
                      Pull.self],
        defaultSubcommand: Query.self)
        
    static var configStoreFileURL: URL {
        return configStoreFolderURL.appendingPathComponent("repostatus.json")
    }

    // MARK: - Private
    
    private static var configStoreFolderURL: URL {
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".config/RepoStatus")
    }
}

