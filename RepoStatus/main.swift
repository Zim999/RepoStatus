//
//  main.swift
//  RepoStatusCommand
//
//  Created by Simon Beavis on 10/5/20.
//

import Foundation
import ArgumentParser

let VersionNumberString = "0.0.1"

RepoStatusCommand.main()

struct RepoStatusCommand: ParsableCommand {

    static let configuration = CommandConfiguration(
        commandName: "RepoStatus",
        abstract: "Display status of Git Repositories",
        subcommands: [Query.self, Config.self, Key.self,
                      AddGroup.self, AddRepo.self,
                      RemoveGroup.self, RemoveRepo.self,
                      Version.self],
        defaultSubcommand: Query.self)
    
    static var configStoreFileURL: URL {
        return configStoreFolderURL.appendingPathComponent("gitstatus.json")
    }

    // MARK: - Private
    
    private static var configStoreFolderURL: URL {
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".config/GitStatus")
    }
}

