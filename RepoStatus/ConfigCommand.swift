//
//  ConfigCommand.swift
//  RepoStatus
//
//  Created by Simon Beavis on 30/12/20.
//

import Foundation
import ArgumentParser

extension RepoStatusCommand {
    struct Config: ParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "config",
            abstract: "Print config file storage path")

        @Flag(name: [.customLong("path"), .customShort("p")],
              help: "Print directory path only")
        var directoryOnly = false

        func run() throws {
            print(directoryOnly ? AppSettings.configFolderURL.path :
                                  AppSettings.collectionStoreFileURL.path)
        }
    }
}
