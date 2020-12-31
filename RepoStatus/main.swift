//
//  main.swift
//  RepoStatusCommand
//
//  Created by Simon Beavis on 10/5/20.
//

import Foundation
import ArgumentParser

RepoStatusCommand.setup()
let collection = RepoCollection(from: RepoStatusCommand.configStoreFileURL)
RepoStatusCommand.main()

struct RepoStatusCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "RepoStatus",
        abstract: "Display status of Git Repositories",
        subcommands: [Query.self, Config.self, Key.self,
                      AddGroup.self, AddRepo.self,
                      RemoveGroup.self, RemoveRepo.self],
        defaultSubcommand: Query.self)
    
    public static func setup(){
        if !createConfigStorageFolder() {
            print("Cannot create configuration storage")
            Darwin.exit(1)
        }
    }
    
    static var configStoreFileURL: URL {
        return configStoreFolderURL.appendingPathComponent("gitstatus.json")
    }

    // MARK: - Private
    
    private static var homeFolderURL: URL {
        return FileManager.default.homeDirectoryForCurrentUser
    }

    private static var configStoreFolderURL: URL {
        return homeFolderURL.appendingPathComponent(".config/GitStatus")
    }

    private static func createConfigStorageFolder() -> Bool {
        do {
            try FileManager.default.createDirectory(at: configStoreFolderURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            return true
        }
        catch {
            return false
        }
    }

}

