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
            abstract: "Print config storage path")
        
        func run() throws {
            print(AppSettings.configFolderURL.path)
        }
    }
}
